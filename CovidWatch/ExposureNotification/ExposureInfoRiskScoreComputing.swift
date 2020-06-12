//
//  Created by Zsombor Szabo on 08/06/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import ExposureNotification

public protocol ExposureRiskScoreComputing {
    func computeRiskScore(
        forAttenuationDurations attenuationDurations: [NSNumber],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore
}
