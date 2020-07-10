//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import ExposureNotification

extension ENRiskScore {

    public enum Level {
        case low, medium, high
    }

    var level: Level {
        switch self {
            case 0...2:
                return .low
            case 3...5:
                return .medium
            case 6...8:
                return .high
            default:
                return .high
        }
    }
}
