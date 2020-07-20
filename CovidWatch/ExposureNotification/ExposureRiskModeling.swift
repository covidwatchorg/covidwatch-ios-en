//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import Foundation
import ExposureNotification

public protocol ExposureRiskModeling {

    func computeRiskScore(
        forExposureInfo exposureInfo: ENExposureInfo
    ) -> ENRiskScore

    func computeRiskScore(
        forAttenuationDurations attenuationDurations: [Double],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore

    func computeRiskLevelValue(
        forExposureInfos exposureInfos: [ENExposureInfo],
        computeDate: Date
    ) -> Double

    func computeTransmissionRiskLevel(
        forTemporaryExposureKey key: ENTemporaryExposureKey,
        symptomsStartDate: Date?,
        testDate: Date?,
        possibleInfectionDate: Date?
    ) -> ENRiskLevel

    func getMostRecentSignificantExposureDate(
        forExposureInfos exposureInfos: [ENExposureInfo]
    ) -> Date?

     func getLeastRecentSignificantExposureDate(
        forExposureInfos exposureInfos: [ENExposureInfo]
     ) -> Date?

    func computeRiskMetrics(
        forExposureInfos exposureInfos: [ENExposureInfo],
        computedDate: Date
    ) -> RiskMetrics
}

public struct RiskMetrics: Codable {
    var riskLevelValue: Double
    var leastRecentSignificantExposureDate: Date?
    var mostRecentSignificantExposureDate: Date?
}
