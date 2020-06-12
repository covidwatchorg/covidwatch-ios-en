//
//  Created by Zsombor Szabo on 08/06/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import ExposureNotification

public class AZExposureRiskScorer: ExposureRiskScoring {
        
    /// According to preliminary dose estimates, the high attenuation distance has a dose 7 times higher than the medium attenuation distance. The mean dose for the low attenuation distance is 0.2 the mean dose of the medium attenuation distance. -AW 6/7/2020
    var attenuationDurationWeights = [
        7.0, // High attenuation: D < 0.5m
        1.0, // Medium attenuation: 0.5m < D < 2m
        0.0002, // Low attenuation: 2m < D
    ]
        
    /// High range shedding ~1010 copies/m3
    /// Medium range shedding ~107 copies/m3 (based on estimates of high asymptomatic shedders)
    /// Low  range shedding ~104
    ///
    /// Then assuming between 0.01% and 1% infectivity. Will use copies/m3 since infectivity assumed to apply the same to these concentrations. In the future, we could relate these concentraitons to cycle threshold values of studies to gain more insights into how fractions of infectivity may vary by concentration
    ///
    /// Transmission risk values increase on a log10 scale, with a 0 transmission level translating to a 0 transmission risk value. These are then multiplied by the time-weighted sum of attenuation. The log10 of this product yields the risk score. Risk scores then translate to risk levels, with assignments described in D2:10 through E2:10. Examples are below.
    var transmissionRiskValuesForLevels = [
        0.00E+00, // Level 0
        1.00E+03, // Level 1
        1.00E+04, // Level 2
        1.00E+06, // Level 3
        1.00E+07, // Level 4
        1.00E+09, // Level 5
        1.00E+10, // Level 6
        1.00E+10, // Level 7 (unused)
    ]
    
    private func computeAttenuationDurationRiskScore(
        forAttenuationDurations attenuationDurations: [NSNumber]
    ) -> Double {
        guard attenuationDurations.count == attenuationDurationWeights.count else {
            return 0.0
        }
        return
            attenuationDurations[0].doubleValue / 60 * attenuationDurationWeights[0] +
            attenuationDurations[1].doubleValue / 60 * attenuationDurationWeights[1] +
            attenuationDurations[2].doubleValue / 60 * attenuationDurationWeights[2]
    }
    
    public func computeRiskScore(
        forAttenuationDurations attenuationDurations: [NSNumber],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore {
        let tranmissionRiskValue = transmissionRiskValuesForLevels[Int(transmissionRiskLevel)]
        let attenuationDurationRiskScore = computeAttenuationDurationRiskScore(
            forAttenuationDurations: attenuationDurations
        )
        let totalRiskScore: AZRiskScoreValue = log10(tranmissionRiskValue * attenuationDurationRiskScore)
        return totalRiskScore.riskScore
    }
}

public typealias AZRiskScoreValue = Double

extension AZRiskScoreValue {
    
    var riskScore: ENRiskScore {
        switch self {
            case -Double.greatestFiniteMagnitude..<3: return 0
            case 3..<5: return 1
            case 5..<6: return 2
            case 6..<7: return 3
            case 7..<8: return 4
            case 8..<9: return 5
            case 9..<10: return 6
            case 10..<11: return 7
            default: return 8
        }
    }
}
