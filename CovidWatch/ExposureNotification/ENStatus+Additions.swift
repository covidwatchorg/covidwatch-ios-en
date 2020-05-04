//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import Foundation
import ExposureNotification

extension ENStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
            case .unknown:
                return NSLocalizedString("EN Unkown Status", comment: "")
            case .active:
                return NSLocalizedString("EN Active", comment: "")
            case .disabled:
                return NSLocalizedString("EN Disabled", comment: "")
            case .bluetoothOff:
                return NSLocalizedString("Bluetooth is Off", comment: "")
            case .restricted:
                return NSLocalizedString("EN Restricted", comment: "")
            @unknown default:
                return ""
        }
    }
    
    public var detailedDescription: String {
        switch self {
            case .unknown:
                return NSLocalizedString("Status of Exposure Notification is unknown.", comment: "")
            case .active:
                return NSLocalizedString("Exposure Notification is active on the system.", comment: "")
            case .disabled:
                return NSLocalizedString("Exposure Notification is disabled.", comment: "")
            case .bluetoothOff:
                return NSLocalizedString("Bluetooth has been turned off on the system. Bluetooth is required for Exposure Notification.", comment: "")
            case .restricted:
                return NSLocalizedString("Exposure Notification is not active due to system restrictions, such as parental controls.", comment: "")
            @unknown default:
                return ""
        }
    }    
}
