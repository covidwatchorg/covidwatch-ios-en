import Foundation
import CoreData
import os.log

struct Operations {
    
    static func getOperationsToFetchLatestPositiveDiagnoses(sinceDate: Date, server: DiagnosisServer) -> [Operation] {
        let downloadFromServer = DownloadPositiveDiagnosesFromServerOperation(
            server: server,
            sinceDate: sinceDate
        )
        let addToEventNotificationFramework = AddPositiveDiagnosesToEventNotificationFramework()
        let passServerResultsToStore = BlockOperation { [unowned downloadFromServer, unowned addToEventNotificationFramework] in
            guard case let .success(entries)? = downloadFromServer.result else {
                addToEventNotificationFramework.cancel()
                return
            }
            addToEventNotificationFramework.entries = entries
        }
        passServerResultsToStore.addDependency(downloadFromServer)
        addToEventNotificationFramework.addDependency(passServerResultsToStore)
        
        return [downloadFromServer,
                passServerResultsToStore,
                addToEventNotificationFramework]
    }
}

class DownloadPositiveDiagnosesFromServerOperation: Operation {
    enum OperationError: Error {
        case cancelled
    }
    
    private let server: DiagnosisServer
    var sinceDate: Date?
    
    var result: Result<[PositiveDiagnosis], Error>?
    
    private var downloading = false
    private var currentDownloadTask: ServerTask?
    
    init(server: DiagnosisServer) {
        self.server = server
    }
    
    convenience init(server: DiagnosisServer, sinceDate: Date?) {
        self.init(server: server)
        self.sinceDate = sinceDate
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        if let currentDownloadTask = currentDownloadTask {
            currentDownloadTask.cancel()
        }
    }
    
    func finish(result: Result<[PositiveDiagnosis], Error>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        currentDownloadTask = nil
        
        switch result {
            case .failure(let error):
                os_log(
                    "Fetching positive diagnoses from server since=%@ failed=%@",
                    log: .app,
                    type: .error,
                    sinceDate?.description ?? "", error as CVarArg
            )
            case .success(let positiveDiagnoses):
                os_log(
                    "Fetched %d positive diagnoses from server since=%@",
                    log: .app,
                    positiveDiagnoses.count,
                    sinceDate?.description ?? ""
            )
        }
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled, let sinceDate = sinceDate else {
            finish(result: .failure(OperationError.cancelled))
            return
        }
        
        os_log("Downloading positive diagnoses from server since=%@ ...", log: .app, sinceDate.description)
        
        currentDownloadTask = server.fetch(since: sinceDate, completion: finish)
    }
}

class AddPositiveDiagnosesToEventNotificationFramework: Operation, DiagnosisKeyProviding {
    
    enum OperationError: Error {
        case timedOut
    }
    
    var entries: [PositiveDiagnosis]?
    var session: ENExposureDetectionSession?
    var summary: ENExposureDetectionSummary?
    var error: Error?
    private var currentIndex = 0
    
    func provide(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        guard let entries = entries, currentIndex < entries.count else {
            completion(.success([]))
            return
        }
        let keysToAdd = entries[currentIndex].diagnosisKeys.map {
            return ENTemporaryExposureKey(keyData: $0.keyData, rollingStartNumber: ENIntervalNumber($0.rollingStartNumber))
        }
        os_log(
            "Processing the %d diagnosis keys of the positive diagnosis with permission number=%@",
            log: .app,
            keysToAdd.count,
            entries[currentIndex].publicHealthAuthorityPermissionNumber
        )
        currentIndex += 1
        completion(.success(keysToAdd))
    }
    
    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        
        os_log(
            "Adding %d positive diagnoses to exposure notification framework ...",
            log: .app,
            entries?.count ?? 0
        )
        ExposureNotificationManager.shared.getExposureDetectionSummary(diagnosisKeyProvider: self) { [weak self] (result) in
            defer {
                semaphore.signal()
            }
            guard let self = self else { return }
            switch result {
                case .failure(let error):
                    self.error = error
                    os_log(
                        "Adding %d positive diagnoses to exposure notification framework failed=%@",
                        log: .app,
                        type: .error,
                        self.entries?.count ?? 0,
                        error as CVarArg
                )
                case .success(let (session, summary)):
                    self.session = session
                    self.summary = summary
                    os_log(
                        "Added %d positive diagnoses to exposure notification framework",
                        log: .app,
                        self.entries?.count ?? 0
                )
            }
        }
        
        semaphore.wait()
    }
}

class AddExposureInfosToCoreData: Operation {
    
    let context: NSManagedObjectContext
    let session: ENExposureDetectionSession
    
    var error: Error?
    
    init(context: NSManagedObjectContext, exposureDetectionSession: ENExposureDetectionSession) {
        self.context = context
        self.session = exposureDetectionSession
    }
    
    override func main() {        
        let semaphore = DispatchSemaphore(value: 0)
        
        os_log(
            "Adding exposure infos from exposure notification framework to core data ...",
            log: .app
        )
        func processNextBatch() {
            if self.isCancelled {
                semaphore.signal()
                return
            }
            session.getExposureInfoWithMaxCount(
                maxCount: 100
            ) { (exposureInfos, inDone, error) in
                if let error = error {
                    self.error = error
                    self.session.invalidate()
                    semaphore.signal()
                    return
                }
                if let exposureInfos = exposureInfos, !exposureInfos.isEmpty {
                    self.store(exposureInfos) { (result) in
                        switch result {
                            case .success():
                                processNextBatch()
                            case .failure(let error):
                                os_log(
                                    "Adding exposure infos from exposure notification framework to core data failed=%@",
                                    log: .app,
                                    type: .error,
                                    error as CVarArg
                                    )
                                self.error = error
                                self.session.invalidate()
                                semaphore.signal()
                                return
                        }
                    }
                } else {
                    os_log(
                        "Added exposure infos from exposure notification framework to core data",
                        log: .app
                    )
                    self.session.invalidate()
                    semaphore.signal()
                }
            }
        }
        
        processNextBatch()
        
        semaphore.wait()
    }
    
    func store(_ exposureInfos: [ENExposureInfo], completion: @escaping (Result<Void, Error>) -> Void) {
        let _ = exposureInfos.map {
            return ManagedExposureInfo(context: context, exposureInfo: $0)
        }
        do {
            try context.save()
            os_log(
                "Added %d exposure info(s) from exposure notification framework to core data",
                log: .app,
                exposureInfos.count
            )
        }
        catch {
            self.error = error
            os_log(
                "Adding exposure infos from exposure notification framework to core data failed=%@",
                log: .app,
                type: .error,
                error as CVarArg
            )
        }
    }
}

