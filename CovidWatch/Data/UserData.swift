//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import CovidWatchExposureNotification
import ExposureNotification

final class UserData: ObservableObject  {
    
    @Published(key: "firstRun")
    var firstRun: Bool = true
    
    @Published(key: "isOnboardingCompleted")
    var isOnboardingCompleted: Bool = false

    @Published(key: "isSetupCompleted")
    var isSetupCompleted: Bool = false {
        didSet {
            if isSetupCompleted {
                isAfterSetup = true
            }
        }
    }
    
    var isAfterSetup: Bool = false
    
    @Published
    var isShowingMenu: Bool = false
    
    @Published(key: "isExposureNotificationsConfigured")
    var isExposureNotificationSetup: Bool = false

    @Published(key: "isNotificationsConfigured")
    var isNotificationsConfigured: Bool = false
    
    @Published
    var exposureNotificationStatus: ENStatus = .active
    
    @Published
    var notificationsAuthorizationStatus: UNAuthorizationStatus = .authorized
    
}
