//
//  Created by Zsombor Szabo on 24/06/2020.
//  
//

import Foundation
import ExposureNotification
import UserNotifications
import os.log
import UIKit

#if DEBUG_CALIBRATION
extension ExposureManager {

    private static let goDeeperQueue = DispatchQueue(label: "com.ninjamonkeycoders.gaen.goDeeper", attributes: .concurrent)

    func calibrationDetectExposures(importURLs: [URL] = [], notifyUserOnError: Bool = false, completionHandler: ((Bool) -> Void)? = nil) -> Progress {
        let progress = Progress()

        // Disallow concurrent exposure detection, because if allowed we might try to detect the same diagnosis keys more than once
        guard !detectingExposures else {
            completionHandler?(false)
            return progress
        }
        detectingExposures = true

        var localURLs = importURLs

        func finish(_ result: Result<Int, Error>) {
            try? Server.shared.deleteDiagnosisKeyFile(at: localURLs)

            let success: Bool
            if progress.isCancelled {
                success = false
            } else {
                switch result {
                // swiftlint:disable empty_enum_arguments
                case .success(_):
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

            self.detectingExposures = false
            completionHandler?(success)
        }

        let actionAfterHasLocalURLs = {
            Server.shared.getExposureConfigurationList { result in
                switch result {
                case let .failure(error):
                    finish(.failure(error))
                case let .success(configurationList):
                    let semaphore = DispatchSemaphore(value: 0)
                    for configuration in configurationList {
                    ExposureManager.shared.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: localURLs) { summary, error in
                            if let error = error {
                                finish(.failure(error))
                                semaphore.signal()
                                return
                            }
                            let userExplanation = NSLocalizedString("USER_NOTIFICATION_EXPLANATION", comment: "User notification")
                            ExposureManager.shared.manager.getExposureInfo(summary: summary!, userExplanation: userExplanation) { exposuresInfos, error in
                                    if let error = error {
                                        finish(.failure(error))
                                        semaphore.signal()
                                        return
                                    }
                                let newExposures: [CodableExposureInfo] = exposuresInfos!.map { exposure in
                                    var totalRiskScore: ENRiskScore = ENRiskScore(exposure.totalRiskScoreFullRange * 8.0 / pow(8, 4))
                                    if let riskModel = self.riskModel {
                                        totalRiskScore = riskModel.computeRiskScore(forExposureInfo: exposure)
                                    }
                                    let e = CodableExposureInfo(
                                        attenuationDurations: exposure.attenuationDurations.map({ $0.doubleValue }),
                                        attenuationValue: exposure.attenuationValue,
                                        date: exposure.date,
                                        duration: exposure.duration,
                                        totalRiskScore: totalRiskScore,
                                        transmissionRiskLevel: exposure.transmissionRiskLevel,
                                        attenuationDurationThresholds: configuration.value(forKey: "attenuationDurationThresholds") as? [Int] ?? [],
                                        timeDetected: Date()
                                    )
                                    return e
                                }
                                os_log(
                                    "Detected exposures count=%d",
                                    log: .en,
                                    exposuresInfos!.count
                                )
                                self.updateSavedExposures(newExposures: newExposures)
                                semaphore.signal()
                            }
                        }
                        semaphore.wait()
                    }
                    finish(.success(localURLs.count))
                }
            }
        }

        ExposureManager.goDeeperQueue.async {
            if localURLs.isEmpty {
                Server.shared.getDiagnosisKeyFileURLs { result in

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
            } else {
                actionAfterHasLocalURLs()
            }

        }
        return progress
    }
}
#endif
