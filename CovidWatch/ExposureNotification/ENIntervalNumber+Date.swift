//
//  Created by Zsombor Szabo on 15/07/2020.
//  
//

import Foundation
import ExposureNotification

extension ENIntervalNumber {

    var date: Date {
        Date(timeIntervalSince1970: ExposureNotificationConstants.intervalLengthSeconds * Double(self))
    }

}
