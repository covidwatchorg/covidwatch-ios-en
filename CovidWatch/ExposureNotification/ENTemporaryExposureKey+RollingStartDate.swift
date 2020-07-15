//
//  Created by Zsombor Szabo on 15/07/2020.
//  
//

import Foundation
import ExposureNotification

extension ENTemporaryExposureKey {

    var rollingStartDate: Date {
        return self.rollingStartNumber.date
    }

}
