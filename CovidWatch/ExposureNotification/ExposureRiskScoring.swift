//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import Foundation
import ExposureNotification

public protocol ExposureRiskScoring {

    func computeRiskScore(forExposure exposure: ENExposureInfo) -> ENRiskScore

    func computeRiskScore(
        forAttenuationDurations attenuationDurations: [NSNumber],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore
    
    func computeCurrentRiskLevel(forExposures exposures: [Exposure]) -> Double
}
