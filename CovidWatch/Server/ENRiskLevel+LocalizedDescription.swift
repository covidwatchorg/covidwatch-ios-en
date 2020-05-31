//
//  Created by Zsombor Szabo on 31/05/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import ExposureNotification

extension ENRiskLevel {
    
    var localizedTransmissionRiskLevelDescription: String {
        switch self {
            case 0:
            return NSLocalizedString("0: Unused", comment: "")
            case 1:
            return NSLocalizedString("1: Confirmed test - Low", comment: "")
            case 2:
            return NSLocalizedString("2: Confirmed test - Standard", comment: "")
            case 3:
            return NSLocalizedString("3: Confirmed test - High", comment: "")
            case 4:
            return NSLocalizedString("4: Confirmed clinical diagnosis", comment: "")
            case 5:
            return NSLocalizedString("5: Self report", comment: "")
            case 6:
            return NSLocalizedString("6: Negative case", comment: "")
            case 7:
            return NSLocalizedString("7: Recursive case", comment: "")
            case 8:
            return NSLocalizedString("8: Unused/custom", comment: "")
            default:
            return ""
        }
    }
    
}
