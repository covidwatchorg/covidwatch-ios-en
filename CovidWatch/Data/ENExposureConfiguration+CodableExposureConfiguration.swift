//
//  Created by Zsombor Szabo on 07/05/2020.
//  
//

import Foundation
import ExposureNotification

@available(iOS 13.6, *)
extension ENExposureConfiguration {

    convenience init(
        _ codableExposureConfiguration: CodableExposureConfiguration
    ) {
        self.init()
        self.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
        self.attenuationLevelValues = codableExposureConfiguration.attenuationLevelValues as [NSNumber]
        self.daysSinceLastExposureLevelValues = codableExposureConfiguration.daysSinceLastExposureLevelValues as [NSNumber]
        self.durationLevelValues = codableExposureConfiguration.durationLevelValues as [NSNumber]
        self.transmissionRiskLevelValues = codableExposureConfiguration.transmissionRiskLevelValues as [NSNumber]
        #if DEBUG_CALIBRATION
        self.metadata = ["attenuationDurationThresholds": codableExposureConfiguration.attenuationDurationThresholdList[0]]
        #else
        self.metadata = ["attenuationDurationThresholds": codableExposureConfiguration.attenuationDurationThresholds]
        #endif
    }
}
