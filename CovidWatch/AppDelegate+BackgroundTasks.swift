//
//  Created by Zsombor Szabo on 29/03/2020.
//

import Foundation
import BackgroundTasks
import os.log
import ExposureNotification
import UIKit
import CovidWatchExposureNotification

extension String {
    
    public static let exposureNotificationBackgroundTaskIdentifier = "org.covidwatch.ios.exposure-notification"
}

extension TimeInterval {
    
    public static let minimumBackgroundFetchTimeInterval: TimeInterval = 60*60*6
}

@available(iOS 13.0, *)
extension AppDelegate {
    
    func registerBackgroundTasks() {
        let taskIdentifiers: [String] = [
            .exposureNotificationBackgroundTaskIdentifier,
        ]
        taskIdentifiers.forEach { identifier in
            let success = BGTaskScheduler.shared.register(
                forTaskWithIdentifier: identifier,
                using: nil
            ) { task in
                os_log(
                    "Start background task=%@",
                    log: .app,
                    identifier
                )
                self.handleBackground(task: task)
            }
            os_log(
                "Register background task=%@ success=%d",
                log: .app,
                type: success ? .default : .error,
                identifier,
                success
            )
        }
    }
    
    func handleBackground(task: BGTask) {
        switch task.identifier {
            case .exposureNotificationBackgroundTaskIdentifier:
                guard let task = task as? BGProcessingTask else { break }
                self.handleBackgroundProcessing(task: task)
            default:
                task.setTaskCompleted(success: false)
        }
    }
    
    func handleBackgroundProcessing(task: BGProcessingTask) {
        // Schedule a new task
        self.scheduleBackgroundProcessingExposureNotificationTaskIfNeeded()
        self.performBackgroundExposureNotification(withTask: task)
    }
    
    public enum PerformFetchError: Error {
        case `internal`
    }
    
    public func performBackgroundExposureNotification(withTask task: BGProcessingTask?) {
        guard !isPerformingBackgroundExposureNotification else { return }
        self.isPerformingBackgroundExposureNotification = true
        
        os_log("Performing background exposure notification ...", log: .app)
        
        let now = Date()
        let oldestDownloadDate = now.addingTimeInterval(-oldestPositiveDiagnosesToFetch)
        var startDate = UserDefaults.standard.lastFetchDate ?? oldestDownloadDate
        if startDate < oldestDownloadDate {
            startDate = oldestDownloadDate
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operations = Operations.getOperationsToFetchLatestPositiveDiagnoses(
            sinceDate: startDate,
            server: self.diagnosisServer,
            context: PersistentContainer.shared.newBackgroundContext()
        )
        
        guard let lastOperation = operations.last as?
            AddExposureInfosFromExposureDetectionSessionToStoreOperation else {
            // Shouldn't get here
            self.isPerformingBackgroundExposureNotification = false
            task?.setTaskCompleted(success: false)
            return
        }
        
        task?.expirationHandler = {
            // After all operations are cancelled, the completion block below is
            // called to set the task to complete.
            queue.cancelAllOperations()
        }
        
        lastOperation.completionBlock = {
            DispatchQueue.main.async {
                defer {
                    self.isPerformingBackgroundExposureNotification = false
                    os_log("Performed background exposure notification ", log: .app)
                }
                
                if !lastOperation.isCancelled,
                    case .success(_) = lastOperation.result {
                    
                    lastOperation.session?.invalidate()
                    
                    if lastOperation.error == nil {
                        UserDefaults.standard.setValue(
                            now,
                            forKey: UserDefaults.Key.lastFetchDate
                        )
                    }
                    task?.setTaskCompleted(success: lastOperation.error == nil)
                } else {
                    task?.setTaskCompleted(success: false)
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    func scheduleBackgroundProcessingExposureNotificationTaskIfNeeded() {
        guard ENManager.authorizationStatus == .authorized else { return }
        let request = BGProcessingTaskRequest(
            identifier: .exposureNotificationBackgroundTaskIdentifier
        )
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(
            timeIntervalSinceNow: .minimumBackgroundFetchTimeInterval
        )
        self.submitTask(request: request)
    }
    
    func submitTask(request: BGTaskRequest) {
        do {
            try BGTaskScheduler.shared.submit(request)
            os_log(
                "Submit task request=%@",
                log: .app,
                request.description
            )
        } catch {
            os_log(
                "Submit task request=%@ failed: %@",
                log: .app,
                type: .error,
                request.description,
                error as CVarArg
            )
        }
    }
}
