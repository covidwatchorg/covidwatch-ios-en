//
//  Created by Zsombor Szabo on 15/07/2020.
//  
//

import Foundation
import ExposureNotification

extension Date {

    var intervalNumber: ENIntervalNumber {
        ENIntervalNumber(self.timeIntervalSince1970 / ExposureNotificationConstants.intervalLengthSeconds)
    }

}
