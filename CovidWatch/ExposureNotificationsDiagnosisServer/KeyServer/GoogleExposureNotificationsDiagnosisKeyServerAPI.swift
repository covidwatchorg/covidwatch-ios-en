//
//  Created by Zsombor Szabo on 01/07/2020.
//  
//

import Foundation
import ExposureNotification

public struct CodablePublishExposure: Codable {
    let temporaryExposureKeys: [CodableDiagnosisKey]
    let regions: [String]
    let appPackageName: String
    let verificationPayload: String
    let hmackey: String
    let padding: String
}

public struct CodableDiagnosisKey: Codable, Equatable {
    let keyData: Data
    let rollingPeriod: ENIntervalNumber
    let rollingStartNumber: ENIntervalNumber
    let transmissionRiskLevel: ENRiskLevel

    enum CodingKeys: String, CodingKey {
        case keyData = "key"
        case rollingPeriod
        case rollingStartNumber
        case transmissionRiskLevel = "transmissionRisk"
    }
}

public struct CodableExposureConfiguration: Codable {
    let minimumRiskScore: ENRiskScore
    #if DEBUG_CALIBRATION
    let attenuationDurationThresholdList: [[Int]]
    #else
    let attenuationDurationThresholds: [Int]
    #endif
    let attenuationLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let durationLevelValues: [ENRiskLevelValue]
    let transmissionRiskLevelValues: [ENRiskLevelValue]
}
