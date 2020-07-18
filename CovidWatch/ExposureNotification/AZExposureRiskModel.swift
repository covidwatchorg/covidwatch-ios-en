//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import Foundation
import ExposureNotification

extension AZExposureRiskModel {

    public struct Configuration {

        var discountSchedule: [Double] = [
            1, 0.99998, 0.994059, 0.9497885, 0.858806, 0.755134, 0.660103392, 0.586894919, 0.533407703, 0.494373128, 0.463039432, 0.438587189, 0.416241392, 0.393207216, 0.367287169, 0.340932595, 0.313997176, 0.286927378, 0.265554932, 0.240765331, 0.217746365, 0.201059905, 0.185435372, 0.172969757, 0.156689676, 0.141405162, 0.124388311, 0.108319101, 0.094752304, 0.081300662, 0.070016527, 0.056302622, 0.044703284, 0.036214683, 0.030309399, 0.024554527, 0.018833743, 0.014769669
        ]

        var attenuationDurationWeights = [
            2.0182978, // High attenuation: D < 0.5m
            1.1507629, // Medium attenuation: 0.5m < D < 2m
            0.6651614 // Low attenuation: 2m < D
        ]

        var doseResponseLambda = 0.0000171

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

        var riskLevelsForDaysIncludingAndBeforeSymptomsStartDay: [ENRiskLevel] = [
            6, 6, 5, 3, 2, 1, 1,
        ]

        var riskLevelsForDaysIncludingAndAfterSymptomsStartDay: [ENRiskLevel] = [
            6, 6, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1,
        ]
        
        var significantRiskThreshold = 0.011
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

    let configuration = AZExposureRiskModel.Configuration()

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

    public func computeDateRiskLevel(
        forExposureInfos exposureInfos: [ENExposureInfo], computeDate: Date
    ) -> Double {
        var dateTransmissionRisks: [Date: Double] = [:]
        for exposure in exposureInfos {
            let newRisk = computeRisk(forExposure: exposure)
            if let prevRisk = dateTransmissionRisks[exposure.date] {
                let combinedRisk = combineRisks(forRisks: [prevRisk, newRisk])
                dateTransmissionRisks[exposure.date] = combinedRisk
            } else {
                dateTransmissionRisks[exposure.date] = newRisk
            }
        }
        var infectedRisk = 0.0
        for (exposureDate, transmissionRisk) in dateTransmissionRisks {
            let diffComponents = Calendar.current.dateComponents([.day], from: exposureDate, to: computeDate)
            let days = diffComponents.day!
            if days >= 0 && days < self.configuration.discountSchedule.count {
                let discountedRisk = transmissionRisk * self.configuration.discountSchedule[days]
                infectedRisk = combineRisks(forRisks: [infectedRisk, discountedRisk])
            }
        }
        let riskLevel = (infectedRisk * 100.0)
        return(riskLevel)
    }

    // TODO: Handle the case when `symptomsStartDate` is unknown, based on Joanna's spreadsheet.
    public func computeTransmissionRiskLevel(
        forTemporaryExposureKey key: ENTemporaryExposureKey,
        symptomsStartDate: Date?
    ) -> ENRiskLevel {
        if let symptomsStartDate = symptomsStartDate {

            let keyRollingStartDate = key.rollingStartDate
            let diffComponents = Calendar.current.dateComponents([.day], from: symptomsStartDate, to: keyRollingStartDate)
            let diffComponentsDay = diffComponents.day ?? .max
            if diffComponentsDay <= 0 {
                let absDiffComponentsDay = abs(diffComponentsDay)
                if absDiffComponentsDay < configuration.riskLevelsForDaysIncludingAndBeforeSymptomsStartDay.count {
                    return configuration.riskLevelsForDaysIncludingAndBeforeSymptomsStartDay[absDiffComponentsDay]
                }
            } else {
                if diffComponentsDay < configuration.riskLevelsForDaysIncludingAndAfterSymptomsStartDay.count {
                    return configuration.riskLevelsForDaysIncludingAndAfterSymptomsStartDay[diffComponentsDay]
                }
            }
        }

        return 0
    }
    
    public func getMostRecentSignificantExposureDate(forExposureInfos exposureInfos: [ENExposureInfo]) -> Date? {
        var dateTransmissionRisks: [Date: Double] = [:]
        for exposure in exposureInfos {
            let newRisk = computeRisk(forExposure: exposure)
            if let prevRisk = dateTransmissionRisks[exposure.date] {
                let combinedRisk = combineRisks(forRisks: [prevRisk, newRisk])
                dateTransmissionRisks[exposure.date] = combinedRisk
            } else {
                dateTransmissionRisks[exposure.date] = newRisk
            }
        }
        var mostRecentSignificantExposureDate : Date?
        for (date, risk) in dateTransmissionRisks {
            if risk >= self.configuration.significantRiskThreshold{
                if let comparisonDate = mostRecentSignificantExposureDate{
                    if date > comparisonDate{
                        mostRecentSignificantExposureDate = date
                    }
                }else{
                    mostRecentSignificantExposureDate = date
                }
            }
        }
        return(mostRecentSignificantExposureDate)
    }
}
