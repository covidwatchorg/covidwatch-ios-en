//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import ExposureNotification

final class UserData: ObservableObject  {
    
    public static let shared = UserData()
    
    @Published(key: "firstRun")
    var firstRun: Bool = true
    
    @Published(key: "isOnboardingCompleted")
    var isOnboardingCompleted: Bool = false
    
    @Published(key: "isSetupCompleted")
    var isSetupCompleted: Bool = false
    
    @Published
    var isExposureNotificationEnabled: Bool = false {
        didSet {
            
            if !ExposureManager.shared.manager.exposureNotificationEnabled &&
                isExposureNotificationEnabled {
                
                ExposureManager.shared.manager.setExposureNotificationEnabled(true) { (error) in
                    
                    if let error = error {
                        UIApplication.shared.topViewController?.present(
                            error as NSError,
                            animated: true,
                            completion: nil
                        )
                        
                        self.isExposureNotificationEnabled = false
                        
                        return
                    }
                }
            }
        }
    }
    
    @Published(key: "isExposureNotificationsConfigured")
    var isExposureNotificationSetup: Bool = false
    
    @Published(key: "isNotificationsConfigured")
    var isNotificationsConfigured: Bool = false
        
    @Published
    var exposureNotificationStatus: ENStatus = .active
    
    @Published
    var notificationsAuthorizationStatus: UNAuthorizationStatus = .authorized
    
}
