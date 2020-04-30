//
//  Created by Zsombor Szabo on 29/03/2020.
//

import Foundation
import BackgroundTasks
import os.log
import ExposureNotification
import UIKit

extension TimeInterval {
    
    // Only fetch signed reports from the past 2 weeks
    public static let oldestPositiveDiagnosesToFetch: TimeInterval = 60*60*24*7*2
    
    // Fetch new signed reports every 6 hours at the earliest
    public static let minimumBackgroundFetchInterval: TimeInterval = 60*60*6
}

extension String {
    
    public static let refreshBackgroundTaskIdentifier = "org.covidwatch.ios.app-refresh"
}

@available(iOS 13.0, *)
extension AppDelegate {
    
    func registerBackgroundTasks() {
        let taskIdentifiers: [String] = [
            .refreshBackgroundTaskIdentifier,
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
            case .refreshBackgroundTaskIdentifier:
                guard let task = task as? BGAppRefreshTask else { break }
                self.handleBackgroundAppRefresh(task: task)
            default:
                task.setTaskCompleted(success: false)
        }
    }
    
    func handleBackgroundAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new task
        self.scheduleBackgroundAppRefreshTask()
        self.performFetch(task: task, completionHandler: nil)
    }
    
    public enum PerformFetchError: Error {
        case `internal`
    }
    
    public func performFetch(task: BGAppRefreshTask?, completionHandler: ((Result<Void, Error>) -> Void)?) {
        guard !isFetching else {
            return
        }
        self.isFetching = true
        if let completionHandler = completionHandler {
            fetchCompletionHandlers.append(completionHandler)
        }
        
        os_log("Performing fetch...", log: .app)
        
        let now = Date()
        let oldestDownloadDate = now.addingTimeInterval(-.oldestPositiveDiagnosesToFetch)
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
            task?.setTaskCompleted(success: false)
            return
        }
        
        task?.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }
        
        lastOperation.completionBlock = {
            DispatchQueue.main.async {
                defer {
                    self.isFetching = false
                }
                let success = !lastOperation.isCancelled
                if success {
                    UserDefaults.shared.setValue(now, forKey: UserDefaults.Key.lastFetchDate)
                    UserDefaults.shared.setValue(lastOperation.summary?.daysSinceLastExposure, forKey: UserDefaults.Key.daysSinceLastExposure)
                    UserDefaults.shared.setValue(lastOperation.summary?.maximumRiskScore, forKey: UserDefaults.Key.maximumRiskScore)
                    UserDefaults.shared.setValue(lastOperation.summary?.matchedKeyCount, forKey: UserDefaults.Key.matchedKeyCount)
                    //                    UserDefaults.shared.setValue(Int.random(in: 1..<20), forKey: UserDefaults.Key.matchedKeyCount)
                    ENExposureDetectionSession.current = lastOperation.session
                    self.fetchCompletionHandlers.forEach({ $0(.success(())) })
                    self.fetchCompletionHandlers.removeAll()
                }
                else {
                    // TODO: Make this part prettier
                    var errorToShow: Error = PerformFetchError.internal
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
                    self.fetchCompletionHandlers.forEach({ $0(.failure(errorToShow)) })
                    self.fetchCompletionHandlers.removeAll()
                }
                task?.setTaskCompleted(success: success)
                os_log("Performed fetch", log: .app)
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    func scheduleBackgroundTasks() {
        self.scheduleBackgroundAppRefreshTask()
    }
    
    func scheduleBackgroundAppRefreshTask() {
        let request = BGAppRefreshTaskRequest(identifier: .refreshBackgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: .minimumBackgroundFetchInterval)
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
