//
//  Created by Zsombor Szabo on 20/09/2017.
//

import UserNotifications
import UIKit
import os.log

// TODO: Clean up this file
extension UNNotificationCategory {
    
    public static let exposureDetectionSummary = "exposureDetectionSummary"
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: User Notification Center
    
    func configureCurrentUserNotificationCenter() {
        let center = UNUserNotificationCenter.current()
        let exposureSummaryCategory = UNNotificationCategory(
            identifier: UNNotificationCategory.exposureDetectionSummary,
            actions: [],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: NSLocalizedString("Exposure Detection Summary", comment: ""),
            categorySummaryFormat: nil, options: []
        )
        center.setNotificationCategories([exposureSummaryCategory])
        center.delegate = self
    }
    
    public func showExposureDetectionSummaryUserNotification(daysSinceLastExposure: Int) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.categoryIdentifier = UNNotificationCategory.exposureDetectionSummary
        notificationContent.sound = .defaultCritical
        // When exporting for localizations Xcode doesn't look for
        // NSString.localizedUserNotificationString(forKey:, arguments:))
        _ = NSLocalizedString("%d day(s) since last exposure", comment: "")
        notificationContent.body = NSString.localizedUserNotificationString(
            forKey: "%d day(s) since last exposure",
            arguments: [daysSinceLastExposure]
        )
        let notificationRequest = UNNotificationRequest(
            identifier: UNNotificationCategory.exposureDetectionSummary,
            content: notificationContent,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        addToCurrentUserNotificationCenterNotificationRequest(notificationRequest)
    }
    
    private func addToCurrentUserNotificationCenterNotificationRequest(
        _ notificationRequest: UNNotificationRequest
    ) {
        UNUserNotificationCenter.current().getNotificationSettings(
            completionHandler: { (settings) in
                
                guard settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional else {
                        return
                }
                UNUserNotificationCenter.current().add(
                    notificationRequest,
                    withCompletionHandler: nil
                )
                os_log(
                    "Added notification request (.identifier=%@ .content.categoryIdentifier=%@ .content.threadIdentifier=%@) to user notification center.",
                    log: .app,
                    notificationRequest.identifier,
                    notificationRequest.content.categoryIdentifier,
                    notificationRequest.content.threadIdentifier
                )
        })
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    func requestUserNotificationAuthorization(provisional: Bool = true) {
        let options: UNAuthorizationOptions = provisional ?
            [.alert, .sound, .badge, .providesAppNotificationSettings, .provisional] :
            [.alert, .sound, .badge, .providesAppNotificationSettings]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: options,
            completionHandler: { (granted, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        UIApplication.shared.topViewController?.present(error as NSError, animated: true)
                        return
                    }
                }
        })
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
    }
}
