//
//  Created by Zsombor Szabo on 20/09/2017.
//

import UserNotifications
import UIKit
import os.log
import SwiftUI

extension UNNotificationCategory {
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: User Notification Center

    func configureCurrentUserNotificationCenter() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
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

    // TODO: File bug, because this doesn't get called for Exposure Notifications.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let viewController = self.window?.rootViewController as? UIHostingController<ContentView> {
            viewController.rootView.presentationMode.wrappedValue.dismiss()
        }
        completionHandler()
    }

    func requestUserNotificationAuthorization(provisional: Bool = true) {
        let options: UNAuthorizationOptions = provisional ?
            [.alert, .sound, .badge, .providesAppNotificationSettings, .provisional] :
            [.alert, .sound, .badge, .providesAppNotificationSettings]

        UNUserNotificationCenter.current().requestAuthorization(
            options: options,
            completionHandler: { (_, error) in

                DispatchQueue.main.async {
                    if let error = error {
                        UIApplication.shared.topViewController?.present(error, animated: true)
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
