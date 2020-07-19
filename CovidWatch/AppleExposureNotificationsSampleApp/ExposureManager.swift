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

    var riskModel: ExposureRiskModeling?

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

    func updateSavedExposures(newExposures: [CodableExposureInfo]) {
        LocalStore.shared.exposuresInfos.append(contentsOf: newExposures)
        LocalStore.shared.exposuresInfos.sort { $0.date > $1.date }
        LocalStore.shared.dateLastPerformedExposureDetection = Date()
        LocalStore.shared.exposureDetectionErrorLocalizedDescription = nil
    }

    public func updateRiskMetricsIfNeeded() {
        if let riskModel = self.riskModel {
            let exposures = LocalStore.shared.exposuresInfos.map({ ENExposureInfo($0) })
            LocalStore.shared.riskMetrics = riskModel.computeRiskMetrics(forExposureInfos: exposures, computedDate: Date())
        }
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
        var newDiagnosisKeyFileURLs = [URL]()

        func finish(_ result: Result<([CodableExposureInfo], [URL]), Error>) {

            try? Server.shared.deleteDiagnosisKeyFile(at: localURLs)

            let success: Bool
            if progress.isCancelled {
                success = false
            } else {
                switch result {
                    case let .success((newExposures, newDiagnosisKeyFileURLs)):
                        LocalStore.shared.previousDiagnosisKeyFileURLs += newDiagnosisKeyFileURLs

                        updateSavedExposures(newExposures: newExposures)

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

        let actionAfterHasLocalURLs = {
            guard !localURLs.isEmpty else {
                self.detectingExposures = false
                LocalStore.shared.dateLastPerformedExposureDetection = Date()
                completionHandler?(true)
                return
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
                                let newExposures: [CodableExposureInfo] = exposures!.map { exposure in

                                    // Map risk score 0-4096 range to 0-8 range.
                                    var totalRiskScore = ENRiskScore(exposure.totalRiskScoreFullRange * 8.0 / pow(8, 4))
                                    // Recompute risk score, if there is a risk model.
                                    if let riskModel = self.riskModel {
                                        totalRiskScore = riskModel.computeRiskScore(forExposureInfo: exposure)
                                    }

                                    let e = CodableExposureInfo(
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
                                finish(.success((newExposures, newDiagnosisKeyFileURLs)))
                            }
                    }

                    case let .failure(error):
                        finish(.failure(error))
                }
            }
        }

        if localURLs.isEmpty {
            Server.shared.getDiagnosisKeyFileURLs { result in

                let dispatchGroup = DispatchGroup()
                var localURLResults = [Result<[URL], Error>]()

                switch result {
                    case let .success(remoteURLs):

                        let previousDiagnosisKeyFileURLs = Set(LocalStore.shared.previousDiagnosisKeyFileURLs)
                        let currentDiagnosisKeyFileURLs = Set(remoteURLs)
                        // Avoid local store to grow endlessly
                        LocalStore.shared.previousDiagnosisKeyFileURLs = Array(previousDiagnosisKeyFileURLs.intersection(currentDiagnosisKeyFileURLs))
                        let newRemoteURLs = currentDiagnosisKeyFileURLs.subtracting(previousDiagnosisKeyFileURLs)
                        newDiagnosisKeyFileURLs = Array(newRemoteURLs)

                        for remoteURL in newRemoteURLs {
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
        } else {
            actionAfterHasLocalURLs()
        }

        return progress
        #endif
    }

    func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        let releaseSameDayKeys = Bundle.main.infoDictionary?[.releaseSameDayKeys] as? Bool ?? false
        if releaseSameDayKeys {
            manager.getTestDiagnosisKeys(completionHandler: completionHandler)
        } else {
            manager.getDiagnosisKeys(completionHandler: completionHandler)
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
