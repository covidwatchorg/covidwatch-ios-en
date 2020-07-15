//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import Foundation

public struct CodableRegion: Codable {

    public enum NextStepType: Int, Codable {
        case info
        case phone
        case website
        case getTestedDates
        case share
    }

    public struct NextStep: Codable, Hashable {
        let type: NextStepType
        let description: String
        let url: String?
    }

    let id: Int
    let name: String
    var logoTypeImageName: String
    var logoImageName: String
    let riskLowThreshold: Double
    let riskHighThreshold: Double
    let nextStepsRiskUnknown: [NextStep]
    let nextStepsRiskLow: [NextStep]
    let nextStepsRiskMedium: [NextStep]
    let nextStepsRiskHigh: [NextStep]
    let nextStepsRiskVerifiedPositive: [NextStep]
}

extension CodableRegion.NextStepType {

    var systemImageName: String {
        switch self {
            case .info:
                return "info.circle.fill"
            case .phone:
                return "phone.fill"
            case .website:
                return "safari.fill"
            case .getTestedDates:
                return "info.circle.fill"
            case .share:
                return "square.and.arrow.up.fill"
        }
    }
}
