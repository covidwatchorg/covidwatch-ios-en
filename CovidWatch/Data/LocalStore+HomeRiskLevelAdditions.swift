//
//  Created by Zsombor Szabo on 12/07/2020.
//  
//

import Foundation
import SwiftUI

extension LocalStore {

    public enum HomeRiskLevel: Int, Codable {
        case low, high, verifiedPositive

        var nextStepsLocalizedDescription: String {
            switch self {
                case .low:
                    return NSLocalizedString("NEXT_STEPS_HOME_RISK_LEVEL_LOW_MESSAGE", comment: "")
                case .high:
                    return NSLocalizedString("NEXT_STEPS_HOME_RISK_LEVEL_HIGH_MESSAGE", comment: "")
                case .verifiedPositive:
                    return NSLocalizedString("NEXT_STEPS_HOME_RISK_LEVEL_VERIFIED_POSITIVE_MESSAGE", comment: "")
            }
        }
    }

    public func updateHomeRiskLevel() {

        if self.diagnoses.contains(where: { $0.isVerified && $0.testType == .testTypeConfirmed }) {
            self.homeRiskLevel = .verifiedPositive
            return
        }

        if let riskMetrics = self.riskMetrics {
            if let mostRecentSignificantExposureDate = riskMetrics.mostRecentSignificantExposureDate {
                let diffComponents = Calendar.current.dateComponents([.day], from: mostRecentSignificantExposureDate, to: Date())
                let diffComponentsDay = diffComponents.day ?? .max
                if diffComponentsDay <= self.region.recentExposureDays {
                    self.homeRiskLevel = .high
                    return
                }

            }
        }

        self.homeRiskLevel = .low
    }

}

extension LocalStore.HomeRiskLevel {

    var color: Color {

        switch self {
            case .low:
                return Color(UIColor.systemGray2)
            default:
                return Color("Risk Level High Color")
        }

    }

    var description: String {

        switch self {
            case .low:
                return NSLocalizedString("RISK_LEVEL_LOW", comment: "")
            case .high:
                return NSLocalizedString("RISK_LEVEL_HIGH", comment: "")
            case .verifiedPositive:
                return NSLocalizedString("RISK_LEVEL_VERIFIED_POSITIVE", comment: "")
        }

    }

    var nextSteps: [CodableRegion.NextStep] {

        switch self {
            case .low:
                return LocalStore.shared.region.nextStepsNoSignificantExposure
            case .high:
                return LocalStore.shared.region.nextStepsSignificantExposure
            case .verifiedPositive:
                return LocalStore.shared.region.nextStepsVerifiedPositive
        }

    }

}
