//
//  Created by Zsombor Szabo on 29/03/2020.
//

import Foundation
import BackgroundTasks
import os.log
import ExposureNotification
import UIKit


extension String {
    
    public static let exposureNotificationBackgroundTaskIdentifier = "org.covidwatch.ios.exposure-notification"
}

extension TimeInterval {
    
    public static let minimumBackgroundFetchTimeInterval: TimeInterval = 60*60*6
}

@available(iOS 13.0, *)
extension AppDelegate {
    
    func setupBackgroundTask() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: .exposureNotificationBackgroundTaskIdentifier, using: .main) { task in
            
            // Notify the user if bluetooth is off
            ExposureManager.shared.showBluetoothOffUserNotificationIfNeeded()
            
            // Perform the exposure detection
            let progress = ExposureManager.shared.detectExposures { success in
                task.setTaskCompleted(success: success)
            }
            
            // Handle running out of time
            task.expirationHandler = {
                progress.cancel()
                LocalStore.shared.exposureDetectionErrorLocalizedDescription = NSLocalizedString("BACKGROUND_TIMEOUT", comment: "ERROR")
            }
            
            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()
        }
        
        scheduleBackgroundTaskIfNeeded()
    }
    
    func scheduleBackgroundTaskIfNeeded() {
        guard ENManager.authorizationStatus == .authorized else { return }
        let taskRequest = BGProcessingTaskRequest(identifier: .exposureNotificationBackgroundTaskIdentifier)
        taskRequest.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            print("Unable to schedule background task: \(error)")
        }
    }
}
