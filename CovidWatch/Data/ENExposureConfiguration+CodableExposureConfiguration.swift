//
//  Created by Zsombor Szabo on 07/05/2020.
//  
//

import Foundation
import ExposureNotification

@available(iOS 13.5, *)
extension ENExposureConfiguration {
    
    convenience init(
        _ codableExposureConfiguration: CodableExposureConfiguration
    ) {
        self.init()
        self.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
        self.attenuationLevelValues = codableExposureConfiguration.attenuationLevelValues as [NSNumber]
        self.attenuationWeight = codableExposureConfiguration.attenuationWeight
        self.daysSinceLastExposureLevelValues = codableExposureConfiguration.daysSinceLastExposureLevelValues as [NSNumber]
        self.daysSinceLastExposureWeight = codableExposureConfiguration.daysSinceLastExposureWeight
        self.durationLevelValues = codableExposureConfiguration.durationLevelValues as [NSNumber]
        self.durationWeight = codableExposureConfiguration.durationWeight
        self.transmissionRiskLevelValues = codableExposureConfiguration.transmissionRiskLevelValues as [NSNumber]
        self.transmissionRiskWeight = codableExposureConfiguration.transmissionRiskWeight
    }        
}
