//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import Foundation
import UserNotifications

extension UNAuthorizationStatus {

    public var localizedDetailDescription: String {
        switch self {
            case .notDetermined:
                return NSLocalizedString("USER_NOTIFICATION_AUTHORIZATION_STATUS_NOT_DETERMINED_DESCRIPTION", comment: "")
            case .denied:
                return NSLocalizedString("USER_NOTIFICATION_AUTHORIZATION_STATUS_DENIED_DESCRIPTION", comment: "")
            case .authorized:
                return NSLocalizedString("USER_NOTIFICATION_AUTHORIZATION_STATUS_AUTHORIZED_DESCRIPTION", comment: "")
            case .provisional:
                return NSLocalizedString("USER_NOTIFICATION_AUTHORIZATION_STATUS_PROVISIONAL_DESCRIPTION", comment: "")
            @unknown default:
                return ""
        }
    }
}
