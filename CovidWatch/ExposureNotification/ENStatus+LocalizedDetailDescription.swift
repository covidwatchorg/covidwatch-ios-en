//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import Foundation
import ExposureNotification

extension ENStatus {

    public var localizedDetailDescription: String {
        switch self {
            case .unknown:
                return NSLocalizedString("EXPOSURE_NOTIFICATION_STATUS_UNKOWN_MESSAGE", comment: "")
            case .active:
                return NSLocalizedString("EXPOSURE_NOTIFICATION_STATUS_ACTIVE_MESSAGE", comment: "")
            case .disabled:
                return NSLocalizedString("EXPOSURE_NOTIFICATION_STATUS_DISABLED_MESSAGE", comment: "")
            case .bluetoothOff:
                return NSLocalizedString("EXPOSURE_NOTIFICATION_STATUS_BLUETOOTH_OFF_MESSAGE", comment: "")
            case .restricted:
                return NSLocalizedString("EXPOSURE_NOTIFICATION_STATUS_RESTRICTED_MESSAGE", comment: "")
            case .paused:
                return NSLocalizedString("EXPOSURE_NOTIFICATION_STATUS_PAUSED_MESSAGE", comment: "")
            @unknown default:
                return ""
        }
    }
}
