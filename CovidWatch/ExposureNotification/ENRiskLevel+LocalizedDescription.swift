//
//  Created by Zsombor Szabo on 31/05/2020.
//  
//

import Foundation
import ExposureNotification

extension ENRiskLevel {

    var localizedTransmissionRiskLevelDescription: String {
        return NSLocalizedString("EN_RISK_LEVEL_\(self)_TITLE", comment: "")
    }

}
