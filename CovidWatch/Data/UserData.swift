//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import ExposureNotification

final class UserData: ObservableObject {

    public static let shared = UserData()

    @Published(key: "firstRun")
    var firstRun: Bool = true

    @Published(key: "isOnboardingCompleted")
    var isOnboardingCompleted: Bool = false

    @Published(key: "isSetupCompleted")
    var isSetupCompleted: Bool = false
    
    @Published
    var isMenuOpened: Bool = false

    @Published(key: "isExposureNotificationSetup")
    var isExposureNotificationSetup: Bool = false

    @Published(key: "isUserNotificationsSetup")
    var isUserNotificationsSetup: Bool = false

    @Published
    var showHomeWelcomeMessage: Bool = false

    @Published
    var exposureNotificationEnabled: Bool = false {
        didSet {
            guard exposureNotificationEnabled != oldValue else { return }

            defer {
                self.configureExposureNotificationStatusMessage()
            }

            guard ENManager.authorizationStatus == .authorized else {
                if ENManager.authorizationStatus != .unknown {
                    if self.exposureNotificationEnabled {
                        withAnimation {
                            
                            self.exposureNotificationEnabled = false
                        }
                    }
                }
                return
            }
 
        }
    }

    @Published
    var exposureNotificationStatus: ENStatus = .active {
        didSet {
            configureExposureNotificationStatusMessage()
        }
    }

    func configureExposureNotificationStatusMessage() {
        self.exposureNotificationStatusMessage =
            self.exposureNotificationStatus.localizedDetailDescription
    }

    @Published
    var exposureNotificationStatusMessage: String = ""

    @Published
    var notificationsAuthorizationStatus: UNAuthorizationStatus = .authorized
}

