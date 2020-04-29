//
//  Created by Zsombor Szabo on 29/03/2020.
//

import UIKit
import os.log
import BackgroundTasks
import CoreData

extension TimeInterval {
    
    // Only fetch signed reports from the past 2 weeks
    public static let oldestSignedReportsToFetch: TimeInterval = 60*60*24*7*2
    
    // Fetch new signed reports every 6 hours at the earliest
    public static let minimumBackgroundFetchInterval: TimeInterval = 60*60*6
}

extension AppDelegate {
    
    // iOS 12 or earlier
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        os_log("Application is about to perform fetch while in the background", log: .app)
        self.performFetch(completionHandler: completionHandler)
    }
    
    public func performFetch(notifyUserOnError: Bool = false, completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        os_log("Performing fetch...", log: .app)
        
        let now = Date()
        let oldestDownloadDate = now.addingTimeInterval(-.oldestSignedReportsToFetch)
        var downloadDate = UserDefaults.shared.lastFetchDate ?? oldestDownloadDate
        if downloadDate < oldestDownloadDate {
            downloadDate = oldestDownloadDate
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operations = Operations.getOperationsToFetchLatestPositiveDiagnoses(
            sinceDate: downloadDate,
            server: self.diagnosisServer            
        )

        guard let lastOperation = operations.last as? AddPositiveDiagnosesToEventNotificationFramework else {
            // Shouldn't get here
            completionHandler?(.failed)
            return
        }
        
        lastOperation.completionBlock = {
            DispatchQueue.main.async {
                let success = !lastOperation.isCancelled
                if success {
                    UserDefaults.shared.setValue(now, forKey: UserDefaults.Key.lastFetchDate)
                    UserDefaults.shared.setValue(lastOperation.summary?.daysSinceLastExposure, forKey: UserDefaults.Key.daysSinceLastExposure)
                    UserDefaults.shared.setValue(lastOperation.summary?.matchedKeyCount, forKey: UserDefaults.Key.matchedKeyCount)
//                    UserDefaults.shared.setValue(Int.random(in: 1..<20), forKey: UserDefaults.Key.matchedKeyCount)
                    ExposureNotificationManager.shared.currentExposureDetectionSession = lastOperation.session
                    completionHandler?(UserDefaults.shared.matchedKeyCount == 0 ? .noData : .newData)
                }
                else {
                    // TODO: Make this part prettier
                    if notifyUserOnError {
                        var errorToShow: Error? = nil
                        for operation in operations {
                            if let operation = operation as? DownloadPositiveDiagnosesFromServerOperation, let result = operation.result {
                                switch result {
                                    case .failure(let error):
                                        errorToShow = error
                                        break
                                    default: ()
                                }
                            }
                            if let operation = operation as? AddPositiveDiagnosesToEventNotificationFramework, let error = operation.error {
                                errorToShow = error
                                break
                            }
                        }
                        if let error = errorToShow {
                            UIApplication.shared.topViewController?.present(error as NSError, animated: true, completion: nil)
                        }
                    }
                    completionHandler?(.failed)
                }
                os_log("Performed fetch", log: .app)
            }
        }

        queue.addOperations(operations, waitUntilFinished: false)   
    }
}
