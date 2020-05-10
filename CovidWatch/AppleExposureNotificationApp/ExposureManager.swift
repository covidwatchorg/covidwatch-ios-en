/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that manages a singleton ENManager object.
*/

import Foundation
import ExposureNotification

@available(iOS 13.5, *)
public class ExposureManager {
    
    public static let shared = ExposureManager()
    
    public let manager = ENManager()
    
    init() {
        manager.activate { _ in
            // Ensure exposure notifications are enabled if the app is authorized. The app
            // could get into a state where it is authorized, but exposure
            // notifications are not enabled,  if the user initially denied Exposure Notifications
            // during onboarding, but then flipped on the "COVID-19 Exposure Notifications" switch
            // in Settings.
            if ENManager.authorizationStatus == .authorized && !self.manager.exposureNotificationEnabled {
                self.manager.setExposureNotificationEnabled(true) { error in
                    // No error handling for attempts to enable on launch
                    if (error == nil) {
                        UserData.shared.isExposureNotificationEnabled = true
                    }
                }
            }
        }
    }
    
    deinit {
        manager.invalidate()
    }
    
    static let authorizationStatusChangeNotification = Notification.Name("ExposureManagerAuthorizationStatusChangedNotification")
    
    var detectingExposures = false
    
    public func detectExposures(completionHandler: ((Bool) -> Void)? = nil) -> Progress {
        
        let progress = Progress()
        
        // Disallow concurrent exposure detection, because if allowed we might try to detect the same diagnosis keys more than once
        guard !detectingExposures else {
            completionHandler?(false)
            return progress
        }
        detectingExposures = true
        
        var localURLs = [URL]()
        
        func finish(_ result: Result<([Exposure], Int), Error>) {
            
            for localURL in localURLs {
                try? Server.shared.deleteDiagnosisKeyFile(at: localURL)
            }
            
            let success: Bool
            if progress.isCancelled {
                success = false
            } else {
                switch result {
                case let .success((newExposures, nextDiagnosisKeyFileIndex)):
                    LocalStore.shared.nextDiagnosisKeyFileIndex = nextDiagnosisKeyFileIndex
                    LocalStore.shared.exposures.append(contentsOf: newExposures)
                    LocalStore.shared.exposures.sort { $0.date < $1.date }
                    LocalStore.shared.dateLastPerformedExposureDetection = Date()
                    LocalStore.shared.exposureDetectionErrorLocalizedDescription = nil
                    success = true
                case let .failure(error):
                    LocalStore.shared.exposureDetectionErrorLocalizedDescription = error.localizedDescription
                    // Consider posting a user notification that an error occured
                    success = false
                }
            }
            
            detectingExposures = false
            completionHandler?(success)
        }
        let nextDiagnosisKeyFileIndex = LocalStore.shared.nextDiagnosisKeyFileIndex
        
        Server.shared.getDiagnosisKeyFileURLs(startingAt: nextDiagnosisKeyFileIndex) { result in
            
            let dispatchGroup = DispatchGroup()
            var localURLResults = [Result<URL, Error>]()
            
            switch result {
            case let .success(remoteURLs):
                for remoteURL in remoteURLs {
                    dispatchGroup.enter()
                    Server.shared.downloadDiagnosisKeyFile(at: remoteURL) { result in
                        localURLResults.append(result)
                        dispatchGroup.leave()
                    }
                }
                
            case let .failure(error):
                finish(.failure(error))
            }
            dispatchGroup.notify(queue: .main) {
                for result in localURLResults {
                    switch result {
                    case let .success(localURL):
                        localURLs.append(localURL)
                    case let .failure(error):
                        finish(.failure(error))
                        return
                    }
                }
                Server.shared.getExposureConfiguration { result in
                    switch result {
                    case let .success(configuration):
                        ExposureManager.shared.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: localURLs) { summary, error in
                            if let error = error {
                                finish(.failure(error))
                                return
                            }
                            let userExplanation = NSLocalizedString("USER_NOTIFICATION_EXPLANATION", comment: "User notification")
                            ExposureManager.shared.manager.getExposureInfo(summary: summary!, userExplanation: userExplanation) { exposures, error in
                                    if let error = error {
                                        finish(.failure(error))
                                        return
                                    }
                                    let newExposures = exposures!.map { exposure in
                                        Exposure(date: exposure.date,
                                                 duration: exposure.duration,
                                                 totalRiskScore: exposure.totalRiskScore,
                                                 transmissionRiskLevel: exposure.transmissionRiskLevel)
                                    }
                                    finish(.success((newExposures, nextDiagnosisKeyFileIndex + localURLs.count)))
                            }
                        }
                        
                    case let .failure(error):
                        finish(.failure(error))
                    }
                }
            }
        }
        
        return progress
    }
    
    public func getAndPostDiagnosisKeys(completion: @escaping (Result<String?, Error>) -> Void) {
        manager.getDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                Server.shared.postDiagnosisKeys(
                    temporaryExposureKeys!,
                    completion: completion
                )
            }
        }
    }
    
    // Includes today's key, requires com.apple.developer.exposure-notification-test entitlement
    public func getAndPostTestDiagnosisKeys(completion: @escaping (Result<String?, Error>) -> Void) {
        manager.getTestDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                Server.shared.postDiagnosisKeys(
                    temporaryExposureKeys!,
                    completion: completion
                )
            }
        }
    }
}
