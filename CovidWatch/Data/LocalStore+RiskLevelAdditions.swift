//
//  Created by Zsombor Szabo on 12/07/2020.
//  
//

import Foundation
import SwiftUI

extension LocalStore {

    public enum HomeRiskLevel: Int, Codable {
        case unknown, low, medium, high, verifiedPositive
    }

    public func updateHomeRiskLevel() {
        if let riskLevelValue = riskLevelValue {

            if diagnoses.contains(where: { $0.isVerified && $0.testType == .testTypeConfirmed }) {
                self.homeRiskLevel = .verifiedPositive
            }

            if riskLevelValue < UserData.shared.region.riskLowThreshold {
                self.homeRiskLevel = .low
            } else if riskLevelValue >= UserData.shared.region.riskLowThreshold && riskLevelValue < UserData.shared.region.riskHighThreshold {
                self.homeRiskLevel = .medium
            } else {
                self.homeRiskLevel = .high
            }

        } else {
            self.homeRiskLevel = .unknown
        }
    }

    var homeRiskLevelColor: Color {

        switch homeRiskLevel {
            case .unknown:
                return Color(UIColor.systemGray2)
            case .low:
                return Color("Risk Level Low Color")
            case .medium:
                return Color("Risk Level Medium Color")
            default:
                return Color("Risk Level High Color")
        }

    }

    var homeRiskLevelDescription: String {

        switch homeRiskLevel {
            case .unknown:
                return NSLocalizedString("RISK_LEVEL_UNKNOWN", comment: "")
            case .low:
                return NSLocalizedString("RISK_LEVEL_LOW", comment: "")
            case .medium:
                return NSLocalizedString("RISK_LEVEL_MEDIUM", comment: "")
            case .high:
                return NSLocalizedString("RISK_LEVEL_HIGH", comment: "")
            case .verifiedPositive:
                return NSLocalizedString("RISK_LEVEL_VERIFIED_POSITIVE", comment: "")
        }

    }

    var homeRiskLevelNextSteps: [CodableRegion.NextStep] {

        switch homeRiskLevel {
            case .unknown:
                return UserData.shared.region.nextStepsRiskUnknown
            case .low:
                return UserData.shared.region.nextStepsRiskLow
            case .medium:
                return UserData.shared.region.nextStepsRiskMedium
            case .high:
                return UserData.shared.region.nextStepsRiskHigh
            case .verifiedPositive:
                return UserData.shared.region.nextStepsRiskVerifiedPositive
        }

    }

    var homeRiskLevelImageName: String {
        switch homeRiskLevel {
            case .unknown:
                return "Risk Level Unknown"
            default:
                return "Risk Level Alert"
        }
    }

}
