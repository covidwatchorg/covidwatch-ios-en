//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import Foundation
import ExposureNotification

public protocol ExposureRiskScoring {

    func computeRiskScore(
        forExposureInfo exposureInfo: ENExposureInfo
    ) -> ENRiskScore

    func computeRiskScore(
        forAttenuationDurations attenuationDurations: [Double],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore

    func computeDateRiskLevel(
        forExposureInfos exposureInfos: [ENExposureInfo],
        computeDate: Date
    ) -> Double

    func computeTransmissionRiskLevel(
        forTemporaryExposureKey key: ENTemporaryExposureKey,
        symptomsStartDate: Date?
    ) -> ENRiskLevel
}
