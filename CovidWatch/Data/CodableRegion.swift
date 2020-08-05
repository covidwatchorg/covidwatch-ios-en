//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import Foundation
import SwiftUI

public struct CodableRegion: Codable {

    public enum RegionID: Int, Codable {
        case arizonaState = 0
        case universityOfArizona
        case arizonaStateUniversity
        case northernArizonaUniversity
    }

    public enum NextStepType: Int, Codable {
        case info
        case phone
        case website
        case share
        case selectRegion
    }

    public struct NextStep: Codable, Hashable {
        let type: NextStepType
        let description: String
        let url: String?
    }

    let id: RegionID
    let name: String
    var isDisabled: Bool = false

    let nextStepsNoSignificantExposure: [NextStep]
    let nextStepsSignificantExposure: [NextStep]
    let nextStepsVerifiedPositive: [NextStep]
    var nextStepsDisabled: [NextStep]?

    let nextStepsVerificationCode: [NextStep]

    let exposureConfiguration: CodableExposureConfiguration = .default

    let azRiskModelConfiguration = AZExposureRiskModel.Configuration()
}

extension CodableRegion {

    var logoTypeImageName: String {
        switch id {
            case .universityOfArizona:
                return "Public Health Authority Logotype - University of Arizona"
            case .arizonaStateUniversity:
                return "Public Health Authority Logotype - Arizona State University"
            case .northernArizonaUniversity:
                return "Public Health Authority Logotype - Northern Arizona University"
            default:
                return "Public Health Authority Logotype - Arizona State"
        }
    }

    var logoImageName: String {
        switch id {
            case .universityOfArizona:
                return "Public Health Authority Logo - University of Arizona"
            case .arizonaStateUniversity:
                return "Public Health Authority Logo - Arizona State University"
            case .northernArizonaUniversity:
                return "Public Health Authority Logo - Northern Arizona University"
            default:
                return "Public Health Authority Logo - Arizona State"
        }
    }
}

extension CodableRegion.NextStepType {

    var image: Image {
        switch self {
            case .info:
                return Image(systemName: "info.circle.fill")
            case .phone:
                return Image("Phone Call")
            case .website:
                return Image("Share Box")
            case .share:
                return Image("Share")
            case .selectRegion:
                return Image("Globe")
        }
    }
}
