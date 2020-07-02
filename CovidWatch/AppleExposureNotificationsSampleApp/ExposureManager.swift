/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that manages a singleton ENManager object.
*/

import Foundation
import ExposureNotification
import UserNotifications
import os.log
import UIKit

class ExposureManager {
    
    static let shared = ExposureManager()
    
    let manager = ENManager()
    
    var riskScorer: ExposureRiskScoring?
    
    init() {
        manager.activate { _ in
            // Ensure exposure notifications are enabled if the app is authorized. The app
            // could get into a state where it is authorized, but exposure
            // notifications are not enabled,  if the user initially denied Exposure Notifications
            // during onboarding, but then flipped on the "COVID-19 Exposure Notifications" switch
            // in Settings.
//            if ENManager.authorizationStatus == .authorized && !self.manager.exposureNotificationEnabled {
//                self.manager.setExposureNotificationEnabled(true) { _ in
//                    // No error handling for attempts to enable on launch
//                }
//            }
        }
    }
    
    deinit {
        manager.invalidate()
    }
    
    func updateSavedExposures(newExposures : [Exposure]) {
        LocalStore.shared.exposures.append(contentsOf: newExposures)
        LocalStore.shared.exposures.sort { $0.date > $1.date }
        LocalStore.shared.dateLastPerformedExposureDetection = Date()
        LocalStore.shared.exposureDetectionErrorLocalizedDescription = nil
    }
    
    static let authorizationStatusChangeNotification = Notification.Name("ExposureManagerAuthorizationStatusChangedNotification")
    
    var detectingExposures = false
    
    func detectExposures(importURLs: [URL] = [], notifyUserOnError: Bool = false, completionHandler: ((Bool) -> Void)? = nil) -> Progress {
        #if DEBUG_CALIBRATION
        return calibrationDetectExposures(importURLs: importURLs, notifyUserOnError: notifyUserOnError, completionHandler: completionHandler)
        #else
        let progress = Progress()
        
        // Disallow concurrent exposure detection, because if allowed we might try to detect the same diagnosis keys more than once
        guard !detectingExposures else {
            completionHandler?(false)
            return progress
        }
        detectingExposures = true
        
        var localURLs = importURLs
        
        func finish(_ result: Result<([Exposure], Int), Error>) {
            
            try? Server.shared.deleteDiagnosisKeyFile(at: localURLs)
            
            let success: Bool
            if progress.isCancelled {
                success = false
            } else {
                switch result {
                    case let .success((newExposures, nextDiagnosisKeyFileIndex)):
                        LocalStore.shared.nextDiagnosisKeyFileIndex = nextDiagnosisKeyFileIndex
                        LocalStore.shared.exposures.append(contentsOf: newExposures)
                        LocalStore.shared.exposures.sort { $0.date > $1.date }
                        LocalStore.shared.dateLastPerformedExposureDetection = Date()
                        LocalStore.shared.exposureDetectionErrorLocalizedDescription = nil
                        success = true
                    case let .failure(error):
                        LocalStore.shared.exposureDetectionErrorLocalizedDescription = error.localizedDescription
                        // Consider posting a user notification that an error occured
                        success = false
                        if notifyUserOnError {
                            UIApplication.shared.topViewController?.present(error as NSError, animated: true)
                    }
                }
            }
            
            detectingExposures = false
            completionHandler?(success)
        }
        let nextDiagnosisKeyFileIndex = LocalStore.shared.nextDiagnosisKeyFileIndex
        
        let actionAfterHasLocalURLs = {
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
                                let newExposures: [Exposure] = exposures!.map { exposure in
                                    // Map score between 0 and 8
                                    var totalRiskScore: ENRiskScore = ENRiskScore(exposure.totalRiskScoreFullRange * 8.0 / pow(8, 4))
                                    if let riskScorer = self.riskScorer {
                                        totalRiskScore = riskScorer.computeRiskScore(forExposure: exposure)
                                    }
                                    
                                    let e = Exposure(
                                        attenuationDurations: exposure.attenuationDurations.map({ $0.doubleValue }),
                                        attenuationValue: exposure.attenuationValue,
                                        date: exposure.date,
                                        duration: exposure.duration,
                                        totalRiskScore: totalRiskScore,
                                        transmissionRiskLevel: exposure.transmissionRiskLevel
                                    )
                                    return e
                                }
                                os_log(
                                    "Detected exposures count=%d",
                                    log: .en,
                                    exposures!.count
                                )
                                finish(.success((newExposures, nextDiagnosisKeyFileIndex + localURLs.count)))
                            }
                    }
                    
                    case let .failure(error):
                        finish(.failure(error))
                }
            }
        }
        
        if localURLs.isEmpty {
            Server.shared.getDiagnosisKeyFileURLs(startingAt: nextDiagnosisKeyFileIndex) { result in
                
                let dispatchGroup = DispatchGroup()
                var localURLResults = [Result<[URL], Error>]()
                
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
                            case let .success(urls):
                                localURLs.append(contentsOf: urls)
                            case let .failure(error):
                                finish(.failure(error))
                                return
                        }
                    }
                    
                    actionAfterHasLocalURLs()
                }
            }
        }
        else {
            actionAfterHasLocalURLs()
        }
        
        return progress
        #endif
    }
    
    func getAndPostDiagnosisKeys(testResult: TestResult, transmissionRiskLevel: ENRiskLevel = 8, completion: @escaping (Error?) -> Void) {
        manager.getDiagnosisKeys { temporaryExposureKeys, error in
//        manager.getTestDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error {
                completion(error)
            } else {
                // In this sample app, transmissionRiskLevel isn't set for any of the diagnosis keys. However, it is at this point that an app could
                // use information accumulated in testResult to determine a transmissionRiskLevel for each diagnosis key.
                temporaryExposureKeys?.forEach { $0.transmissionRiskLevel = transmissionRiskLevel }
                Server.shared.postDiagnosisKeys(temporaryExposureKeys!) { error in
                    completion(error)
                }
            }
        }
    }
    
    // Includes today's key, requires com.apple.developer.exposure-notification-test entitlement
    func getAndPostTestDiagnosisKeys(completion: @escaping (Error?) -> Void) {
        manager.getTestDiagnosisKeys { temporaryExposureKeys, error in
            if let error = error {
                completion(error)
            } else {
                Server.shared.postDiagnosisKeys(temporaryExposureKeys!) { error in
                    completion(error)
                }
            }
        }
    }
    
    func showBluetoothOffUserNotificationIfNeeded() {
        let identifier = "bluetooth-off"
        if ENManager.authorizationStatus == .authorized && manager.exposureNotificationStatus == .bluetoothOff {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("USER_NOTIFICATION_BLUETOOTH_OFF_TITLE", comment: "User notification title")
            content.body = NSLocalizedString("USER_NOTIFICATION_BLUETOOTH_OFF_BODY", comment: "User notification")
            content.sound = .default
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        os_log(
                            "Showing error user notification failed=%@ ...",
                            log: .app,
                            type: .error,
                            error as CVarArg
                        )
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        }
    }
}
