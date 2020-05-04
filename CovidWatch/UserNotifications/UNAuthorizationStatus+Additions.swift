//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import Foundation
import UserNotifications

extension UNAuthorizationStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
            case .notDetermined:
                return NSLocalizedString("Notifications Not Determined", comment: "")
            case .denied:
                return NSLocalizedString("Notifications Denied", comment: "")
            case .authorized:
                return NSLocalizedString("Notifications Authorized", comment: "")
            case .provisional:
                return NSLocalizedString("Notifications Provisional", comment: "")
            @unknown default:
                return ""
        }
    }
    
    public var detailedDescription: String {
        switch self {
            case .notDetermined:
                return NSLocalizedString("The user has not yet made a choice regarding whether the application may post user notifications.", comment: "")
            case .denied:
                return NSLocalizedString("The application is not authorized to post user notifications.", comment: "")
            case .authorized:
                return NSLocalizedString("The application is authorized to post user notifications.", comment: "")
            case .provisional:
                return NSLocalizedString("The application is authorized to post non-interruptive user notifications.", comment: "")
            @unknown default:
                return ""
        }
    }
}
