//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import Foundation
import ExposureNotification

public class AZExposureRiskScorer: ExposureRiskScoring {
        
    var attenuationDurationWeights = [
        2.0182978, // High attenuation: D < 0.5m
        1.1507629, // Medium attenuation: 0.5m < D < 2m
        0.6651614, // Low attenuation: 2m < D
    ]
    
    var doseResponseLambda = 1.71E-05
        
    var transmissionRiskValuesForLevels: [Double] = [
        0.00E+00, // Level 0
        1.00E+01, // Level 1
        pow(10,(1+2/6)), // Level 2
        pow(10,(1+3/6)), // Level 3
        pow(10,(1+4/6)), // Level 4
        pow(10,(1+5/6)), // Level 5
        pow(10,(1+6/6)), // Level 6
        pow(10,(1+7/6)), // Level 7 (unused)
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
    
    public func computeRiskScore(forExposure exposure: ENExposureInfo) -> ENRiskScore {
        return computeRiskScore(forAttenuationDurations: exposure.attenuationDurations, transmissionRiskLevel: exposure.transmissionRiskLevel)
    }
    
    public func computeRiskScore(
        forAttenuationDurations attenuationDurations: [NSNumber],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore {
        let tranmissionRiskValue = transmissionRiskValuesForLevels[Int(transmissionRiskLevel)]
        let attenuationDurationRiskScore = computeAttenuationDurationRiskScore(
            forAttenuationDurations: attenuationDurations
        )
        let totalRiskScore: AZRiskScoreValue = (1 - exp(-doseResponseLambda * tranmissionRiskValue * attenuationDurationRiskScore)) * 100
        return totalRiskScore.riskScore
    }
}

public typealias AZRiskScoreValue = Double

extension AZRiskScoreValue {
    
    var riskScore: ENRiskScore {
        switch self {
            case -Double.greatestFiniteMagnitude..<1: return 0
            case 1..<1.5: return 1
            case 1.5..<2: return 2
            case 2..<2.5: return 3
            case 2.5..<3: return 4
            case 3..<3.5: return 5
            case 3.5..<4: return 6
            case 4..<4.5: return 7
            default: return 8
        }
    }
}
