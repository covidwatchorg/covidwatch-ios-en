//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import CoreData
import os.log
import ExposureNotification

struct Operations {
    
    static func getOperationsToFetchLatestPositiveDiagnoses(sinceDate: Date, server: DiagnosisServer) -> [Operation] {
        let downloadFromServer = DownloadPositiveDiagnosesFromServerOperation(
            server: server,
            sinceDate: sinceDate
        )
        let addToStore = AddPositiveDiagnosesToEventNotificationFramework()
        let passServerResultsToStore = BlockOperation { [unowned downloadFromServer, unowned addToStore] in
            guard case let .success(entries)? = downloadFromServer.result else {
                addToStore.cancel()
                return
            }
            addToStore.entries = entries
        }
        passServerResultsToStore.addDependency(downloadFromServer)
        addToStore.addDependency(passServerResultsToStore)
        
        return [downloadFromServer,
                passServerResultsToStore,
                addToStore]
    }
}

enum OperationError: Error {
    case cancelled
}

class DownloadPositiveDiagnosesFromServerOperation: Operation {
    
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

protocol DiagnosisKeyProviding {
    func provide(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void)
}

public enum ExposureNotificationManagerError: Error {
    case missingExposureDetectionSummary
}

class AddPositiveDiagnosesToEventNotificationFramework: Operation, DiagnosisKeyProviding {
    
    // Input
    var entries: [PositiveDiagnosis]?
    
    // Output
    var session: ENExposureDetectionSession?
    var summary: ENExposureDetectionSummary?
    var error: Error?
    
    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        
        os_log(
            "Adding %d positive diagnoses to exposure notification framework ...",
            log: .app,
            entries?.count ?? 0
        )
        
        // TODO: Modify properties of this object, if needed.
        let configuration = ENExposureConfiguration()
        
        getExposureDetectionSummary(
            diagnosisKeyProvider: self,
            exposureConfiguration: configuration
        ) { (result) in
            defer {
                semaphore.signal()
            }
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
    
    private var currentIndex = 0
    
    func provide(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        guard let entries = entries, currentIndex < entries.count else {
            completion(.success([]))
            return
        }
        let keysToAdd: [ENTemporaryExposureKey] = entries[currentIndex].diagnosisKeys.map {
            ENTemporaryExposureKey($0)
        }
        os_log(
            "Processing the %d diagnosis keys of the positive diagnosis with permission number=%@",
            log: .app,
            keysToAdd.count,
            entries[currentIndex].publicHealthAuthorityPermissionNumber ?? ""
        )
        currentIndex += 1
        completion(.success(keysToAdd))
    }
    
    func getExposureDetectionSummary(
        diagnosisKeyProvider: DiagnosisKeyProviding,
        exposureConfiguration: ENExposureConfiguration,
        completion: @escaping (Result<(ENExposureDetectionSession, ENExposureDetectionSummary), Error>) -> Void
    ) {
        
        let session = ENExposureDetectionSession()
        session.configuration = exposureConfiguration
        
        session.activate { error in
            if let error = error {
                session.invalidate()
                completion(.failure(error))
                return
            }
            
            func processNextBatch() {
                if self.isCancelled {
                    session.invalidate()
                    completion(.failure(OperationError.cancelled))
                    return
                }
                diagnosisKeyProvider.provide { result in
                    
                    switch result {
                        
                        case .failure(let error):
                            session.invalidate()
                            completion(.failure(error))
                        
                        case .success(var keysToAdd):
                            guard keysToAdd.count > 0 else {
                                session.finishedDiagnosisKeys { (summary, error) in
                                    if let error = error {
                                        session.invalidate()
                                        completion(.failure(error))
                                        return
                                    }
                                    guard let summary = summary else {
                                        session.invalidate()
                                        completion(.failure(ExposureNotificationManagerError.missingExposureDetectionSummary))
                                        return
                                    }
                                    completion(.success((session, summary)))
                                }
                                return
                            }
                            
                            func processKeysToAdd() {
                                if self.isCancelled {
                                    session.invalidate()
                                    completion(.failure(OperationError.cancelled))
                                    return
                                }
                                session.addDiagnosisKeys(Array(keysToAdd.prefix(session.maximumKeyCount))) { (error) in
                                    
                                    if let error = error {
                                        session.invalidate()
                                        completion(.failure(error))
                                        return
                                    }
                                    
                                    if keysToAdd.count >= session.maximumKeyCount {
                                        keysToAdd.removeFirst(session.maximumKeyCount)
                                    } else {
                                        keysToAdd.removeAll()
                                    }
                                    
                                    if !keysToAdd.isEmpty {
                                        processKeysToAdd()
                                    }
                                    else {
                                        processNextBatch()
                                    }
                                }
                            }
                            
                            processKeysToAdd()
                    }
                }
            }
            
            processNextBatch()
        }
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
                self.error = OperationError.cancelled
                return
            }
            session.getExposureInfo(withMaximumCount: 100) { (exposureInfos, inDone, error) in
                if let error = error {
                    self.error = error
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
                                semaphore.signal()
                                return
                        }
                    }
                } else {
                    os_log(
                        "Added exposure infos from exposure notification framework to core data",
                        log: .app
                    )
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

