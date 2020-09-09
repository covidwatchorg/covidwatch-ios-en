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
        case bermuda
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
    var recentExposureDays: Int = 14

    let nextStepsNoSignificantExposure: [NextStep]
    let nextStepsSignificantExposure: [NextStep]
    let nextStepsVerifiedPositive: [NextStep]

    let nextStepsVerificationCode: [NextStep]

    var exposureConfiguration: CodableExposureConfiguration = .default

    var azRiskModelConfiguration = AZExposureRiskModel.Configuration()
}

extension CodableRegion.NextStepType {

    public var callToActionLocalizedMessage: String {
        switch self {
            case .info:
                return NSLocalizedString("WHERE_IS_MY_CODE_INFO", comment: "")
            case .phone:
                return NSLocalizedString("WHERE_IS_MY_CODE_PHONE", comment: "")
            case .website:
                return NSLocalizedString("WHERE_IS_MY_CODE_WEBSITE", comment: "")
            case .share:
                return NSLocalizedString("WHERE_IS_MY_CODE_SHARE", comment: "")
            case .selectRegion:
                return NSLocalizedString("WHERE_IS_MY_CODE_SELECT_REGION", comment: "")
        }
    }
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
            case .bermuda:
                return "Public Health Authority Logotype - Bermuda"
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
            case .bermuda:
                return "Public Health Authority Logo - Bermuda"
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

extension CodableRegion.NextStep {

    static let infoAppIsActive: Self = .init(
        type: .info,
        description: "The app is active. You can now receive exposure notifications from others you were near who later report themselves as positive for COVID-19.",
        url: nil
    )

    static let infoKeepAppInstalled: Self = .init(
        type: .info,
        description: "Keep the app installed until the pandemic is over so that you can continue to help reduce the spread in your communities.",
        url: nil
    )

    static let shareTheApp: Self = .init(
        type: .share,
        description: "Share the app to improve your exposure notification accuracy.",
        url: "https://covidwatch.org"
    )

    static let whyDidIReceiveAnExposureNotification: Self = .init(
        type: .website,
        description: "Why would I receive a COVID-19 exposure notification?",
        url: "https://covidwatch.zendesk.com/hc/en-us/articles/360052305514-Why-did-I-receive-a-possible-COVID-19-exposure-notification"
    )
}
