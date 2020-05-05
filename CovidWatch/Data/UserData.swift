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
                isRightAfterSetup = true
            }
        }
    }
    
    var isRightAfterSetup: Bool = false
    
    @Published
    var isShowingMenu: Bool = false
    
    @Published(key: "isExposureNotificationsConfigured")
    var isExposureNotificationSetup: Bool = false
    
    @Published(key: "isNotificationsConfigured")
    var isNotificationsConfigured: Bool = false
    
    @Published(key: "lastReportDate")
    var lastReportDate: Date = .distantPast
    
    var isAfterSubmitReport: Bool = false {
        didSet {
            self.isRightAfterSetup = false
        }
    }
    
    @Published(key: "daysSinceLastExposure")
    var daysSinceLastExposure: Int = 1 // Testing
    
    @Published(key: "matchedKeyCount")
    var matchedKeyCount: Int = 1 // Testing
    
    @Published(key: "maximumRiskScore")
    var maximumRiskScore: Int = 0
    
    @Published
    var exposureNotificationStatus: ENStatus = .active
    
    @Published
    var notificationsAuthorizationStatus: UNAuthorizationStatus = .authorized
    
}
