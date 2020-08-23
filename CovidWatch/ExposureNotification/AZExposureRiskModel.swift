//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import Foundation
import ExposureNotification

extension AZExposureRiskModel {

    public struct Configuration: Codable {

        var discountSchedule: [Double] = [
            1, 0.99998, 0.994059, 0.9497885, 0.858806, 0.755134, 0.660103392, 0.586894919, 0.533407703, 0.494373128, 0.463039432, 0.438587189, 0.416241392, 0.393207216, 0.367287169, 0.340932595, 0.313997176, 0.286927378, 0.265554932, 0.240765331, 0.217746365, 0.201059905, 0.185435372, 0.172969757, 0.156689676, 0.141405162, 0.124388311, 0.108319101, 0.094752304, 0.081300662, 0.070016527, 0.056302622, 0.044703284, 0.036214683, 0.030309399, 0.024554527, 0.018833743, 0.014769669
        ]

        var attenuationDurationWeights = [
            2.39, // Low attenuation / close proximity
            0.6, // Medium attenuation / medium proximity
            0.06 // high attenuation / far proximity
        ]

        var doseResponseLambda = 0.0000031

        var transmissionRiskValuesForLevels: [Double] = [
            0, // Level 0
            10, // Level 1
            21.5443469, // Level 2
            31.6227766, // Level 3
            46.4158883, // Level 4
            68.1292069, // Level 5
            100, // Level 6
            100 // Level 7 (unused)
        ]

        var riskLevelsForDaysRelativeToSymptomsStartDay: [Int: ENRiskLevel] = [
            -5: 1, -4: 3, -3: 4, -2: 5, -1: 6, 0: 6, 1: 6, 2: 6, 3: 5, 4: 4, 5: 3, 6: 2, 7: 2, 8: 1, 9: 1
        ]

        var riskLevelsForDaysRelativeToTestDay: [Int: ENRiskLevel] = [
            -4: 2, -3: 2, -2: 2, -1: 3, 0: 3, 1: 3, 2: 2, 3: 2, 4: 2
        ]

        var excludeDaysRelativeToPossibleInfectedDay: [Int] = [0, 1]

        var significantRiskLevelValueThreshold = 0.01
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

public class AZExposureRiskModel: ExposureRiskModeling {

    var configuration: AZExposureRiskModel.Configuration

    init(configuration: AZExposureRiskModel.Configuration = .init()) {
        self.configuration = configuration
    }

    private func computeAttenuationDurationRiskScore(
        forAttenuationDurations attenuationDurations: [Double]
    ) -> Double {
        // iOS 13.6 silently introduced a 4th attenuation bucket, but our weight vector is only set for 3 buckets
        guard attenuationDurations.count >= self.configuration.attenuationDurationWeights.count else {
            return 0.0
        }
        return
            attenuationDurations[0] / 60 * self.configuration.attenuationDurationWeights[0] +
                attenuationDurations[1] / 60 * self.configuration.attenuationDurationWeights[1] +
                attenuationDurations[2] / 60 * self.configuration.attenuationDurationWeights[2]
    }

    public func computeRiskScore(
        forExposureInfo exposure: ENExposureInfo
    ) -> ENRiskScore {

        return computeRiskScore(
            forAttenuationDurations: exposure.attenuationDurations.map({ $0.doubleValue }),
            transmissionRiskLevel: exposure.transmissionRiskLevel
        )
    }

    public func computeRiskScore(
        forAttenuationDurations attenuationDurations: [Double],
        transmissionRiskLevel: ENRiskLevel
    ) -> ENRiskScore {

        let tranmissionRiskValue = self.configuration.transmissionRiskValuesForLevels[Int(transmissionRiskLevel)]
        let attenuationDurationRiskScore = computeAttenuationDurationRiskScore(
            forAttenuationDurations: attenuationDurations
        )
        let totalRiskScore: AZRiskScoreValue = (1 - exp(-self.configuration.doseResponseLambda * tranmissionRiskValue * attenuationDurationRiskScore)) * 100
        return totalRiskScore.riskScore
    }

    private func computeRisk(
        forExposure exposure: ENExposureInfo
    ) -> Double {

        return computeRisk(
            forAttenuationDurations: exposure.attenuationDurations.map({ $0.doubleValue }),
            transmissionRiskLevel: exposure.transmissionRiskLevel
        )
    }

    private func computeRisk(
        forAttenuationDurations attenuationDurations: [Double],
        transmissionRiskLevel: ENRiskLevel
    ) -> Double {

        let tranmissionRiskValue = self.configuration.transmissionRiskValuesForLevels[Int(transmissionRiskLevel)]
        let attenuationDurationRiskScore = computeAttenuationDurationRiskScore(
            forAttenuationDurations: attenuationDurations
        )
        let totalRiskScore = (1 - exp(-self.configuration.doseResponseLambda * tranmissionRiskValue * attenuationDurationRiskScore))
        return totalRiskScore
    }

    private func combineRisks(
        forRisks risks: [Double]
    ) -> Double {

        var inverseProduct = 1.0
        for risk in risks {
            inverseProduct = inverseProduct * (1.0 - risk)
        }
        return (1.0 - inverseProduct)
    }

    public func computeRiskLevelValue(
        forExposureInfos exposureInfos: [ENExposureInfo], computeDate: Date
    ) -> Double {

        let dateExposureRisks = getDateExposureRisks(forExposureInfos: exposureInfos)

        var infectedRisk = 0.0
        for (exposureDate, transmissionRisk) in dateExposureRisks {
            let diffComponents = Calendar.current.dateComponents([.day], from: exposureDate, to: computeDate)
            let days = diffComponents.day!
            if days >= 0 && days < self.configuration.discountSchedule.count {
                let discountedRisk = transmissionRisk * self.configuration.discountSchedule[days]
                infectedRisk = combineRisks(forRisks: [infectedRisk, discountedRisk])
            }
        }
        let riskLevel = (infectedRisk * 100.0)
        return riskLevel
    }

    public func computeTransmissionRiskLevel(
        forTemporaryExposureKey key: ENTemporaryExposureKey,
        symptomsStartDate: Date?,
        testDate: Date?,
        possibleInfectionDate: Date?
    ) -> ENRiskLevel {

        let keyRollingStartDate = key.rollingStartDate

        if let symptomStartDate = symptomsStartDate {
            let relativeSymptomDay = relativeDay(from: symptomStartDate, to: keyRollingStartDate)
            if let risk = configuration.riskLevelsForDaysRelativeToSymptomsStartDay[relativeSymptomDay] {
                return risk
            } else {
                return 0
            }
        } else if let testDate = testDate {
            let relativeTestDay = relativeDay(from: testDate, to: keyRollingStartDate)
            if let risk = configuration.riskLevelsForDaysRelativeToTestDay[relativeTestDay] {
                if let possibleInfectionDate = possibleInfectionDate {
                    let relativeInfectionDay = relativeDay(from: possibleInfectionDate, to: keyRollingStartDate)
                    if configuration.excludeDaysRelativeToPossibleInfectedDay.contains(relativeInfectionDay) {
                        return 0
                    }
                }
                return risk
            }
        }

        return 0
    }

    private func getDateExposureRisks(
        forExposureInfos exposureInfos: [ENExposureInfo]
    ) -> [Date: Double] {

        var dateExposureRisks: [Date: Double] = [:]
        for exposure in exposureInfos {
            let newRisk = computeRisk(forExposure: exposure)
            if let prevRisk = dateExposureRisks[exposure.date] {
                let combinedRisk = combineRisks(forRisks: [prevRisk, newRisk])
                dateExposureRisks[exposure.date] = combinedRisk
            } else {
                dateExposureRisks[exposure.date] = newRisk
            }
        }
        return dateExposureRisks
    }

    public func getMostRecentSignificantExposureDate(
        forExposureInfos exposureInfos: [ENExposureInfo]
    ) -> Date? {

        let dateExposureRisks = getDateExposureRisks(forExposureInfos: exposureInfos)

        let mostRecentSignificantExposure = dateExposureRisks
            .filter({ $0.value >= self.configuration.significantRiskLevelValueThreshold })
            .max(by: ({ $0.key < $1.key }))

        return mostRecentSignificantExposure?.key
    }

    public func getLeastRecentSignificantExposureDate(
        forExposureInfos exposureInfos: [ENExposureInfo]
    ) -> Date? {

        let dateExposureRisks = getDateExposureRisks(forExposureInfos: exposureInfos)

        let leastRecentSignificantExposureDate = dateExposureRisks
            .filter({ $0.value >= self.configuration.significantRiskLevelValueThreshold })
            .min(by: ({ $0.key < $1.key }))

        return leastRecentSignificantExposureDate?.key
    }

    public func computeRiskMetrics(
        forExposureInfos exposureInfos: [ENExposureInfo],
        computedDate: Date = Date()
    ) -> RiskMetrics {

        let riskMetrics = RiskMetrics(
            riskLevelValue: computeRiskLevelValue(forExposureInfos: exposureInfos, computeDate: computedDate),
            leastRecentSignificantExposureDate: getLeastRecentSignificantExposureDate(forExposureInfos: exposureInfos),
            mostRecentSignificantExposureDate: getMostRecentSignificantExposureDate(forExposureInfos: exposureInfos)
        )
        return riskMetrics
    }
}

func relativeDay(from startDate: Date, to endDate: Date) -> Int {
    let diffComponents = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
    return diffComponents.day ?? .max
}
