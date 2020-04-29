//
//  Created by Zsombor Szabo on 26/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import UIKit

protocol DiagnosisKeyProviding {
    func provide(completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void)
}

protocol ExposureInfoStoring {
    func store(_ exposureInfos: [ENExposureInfo], completion: @escaping (Result<Void, Error>) -> Void)
}

public enum ExposureNotificationManagerError: Error {
    case missingSettings
    case missingExposureDetectionSummary
    case missingSelfExposureInfo
}

class ExposureNotificationManager {
    
    static let shared = ExposureNotificationManager()
    
    var currentExposureDetectionSession: ENExposureDetectionSession? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    public var dispatchQueue = DispatchQueue(label: String(describing: ExposureNotificationManager.self))
    
    public func getSettings(
        completion: @escaping (Result<ENSettings, Error>) -> Void
    ) {
        let request = ENSettingsGetRequest()
        request.dispatchQueue = self.dispatchQueue
        
        request.activateWithCompletion { error in
            defer {
                request.invalidate()
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let settings = request.settings else {
                completion(.failure(ExposureNotificationManagerError.missingSettings))
                return
            }
            completion(.success(settings))
        }
    }
    
    public func changeSettings(
        _ settings: ENMutableSettings,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let request = ENSettingsChangeRequest(settings: settings)
        request.dispatchQueue = self.dispatchQueue
        
        request.activateWithCompletion { error in
            defer {
                request.invalidate()
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    public func getExposureDetectionSummary(
        diagnosisKeyProvider: DiagnosisKeyProviding,
        attenuationThreshold: UInt8 = 0,
        durationThreshold: TimeInterval = 0,
        completion: @escaping (Result<(ENExposureDetectionSession, ENExposureDetectionSummary), Error>) -> Void
    ) {
        
        let session = ENExposureDetectionSession()
        session.attenuationThreshold = attenuationThreshold
        session.durationThreshold = durationThreshold
        session.dispatchQueue = self.dispatchQueue
        
        session.activateWithCompletion { error in
            if let error = error {
                session.invalidate()
                completion(.failure(error))
                return
            }
            
            func processNextBatch() {
                diagnosisKeyProvider.provide { result in
                    
                    switch result {
                        
                        case .failure(let error):
                            session.invalidate()
                            completion(.failure(error))
                        
                        case .success(let keysToAdd):
                            guard keysToAdd.count > 0 else {
                                session.finishedDiagnosisKeysWithCompletion { (summary, error) in
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
                            session.maxKeyCount = keysToAdd.count
                            session.addDiagnosisKeys(inKeys: keysToAdd) { (error) in
                                if let error = error {
                                    session.invalidate()
                                    completion(.failure(error))
                                    return
                                }
                                processNextBatch()
                        }
                        
                    }
                }
            }
            
            processNextBatch()
        }
    }
    
    public func getExposureInfoWithMaxCount(
        _ maxCount: UInt32 = 100,
        session: ENExposureDetectionSession,
        exposureInfoStorage: ExposureInfoStoring,
        isCancelled: inout Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        func processNextBatch() {
            session.getExposureInfoWithMaxCount(
                maxCount: maxCount
            ) { (exposureInfos, inDone, error) in
                if let error = error {
                    session.invalidate()
                    completion(.failure(error))
                    return
                }
                if let exposureInfos = exposureInfos, !exposureInfos.isEmpty {
                    exposureInfoStorage.store(exposureInfos) { (result) in
                        switch result {
                            case .success():
                                processNextBatch()
                            case .failure(let error):
                                session.invalidate()
                                completion(.failure(error))
                                return
                        }
                    }
                } else {
                    session.invalidate()
                    completion(.success(()))
                }
            }
        }
        
        processNextBatch()
    }
    
    public func getSelfExposureInfo(
        completion: @escaping (Result<ENSelfExposureInfo, Error>
        ) -> Void) {
        
        let request = ENSelfExposureInfoRequest()
        request.dispatchQueue = self.dispatchQueue
        
        request.activateWithCompletion { (error) in
            defer {
                request.invalidate()
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let selfExposureInfo = request.selfExposureInfo else {
                completion(.failure(ExposureNotificationManagerError.missingSelfExposureInfo))
                return
            }
            completion(.success(selfExposureInfo))
        }
    }
    
    public func resetSelfExposure(
        completion: @escaping (Result<Void, Error>
        ) -> Void) {
        
        let request = ENSelfExposureResetRequest()
        request.dispatchQueue = self.dispatchQueue
        
        request.activateWithCompletion { (error) in
            defer {
                request.invalidate()
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
}
