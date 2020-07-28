//
//  Created by Zsombor Szabo on 15/07/2020.
//  
//

import Foundation
import ExposureNotification

@available(iOS 13.6, *)
extension ENExposureInfo {

    convenience init(_ exposureInfo: CodableExposureInfo) {
        self.init(
            attenuationDurations: exposureInfo.attenuationDurations,
            attenuationValue: exposureInfo.attenuationValue,
            date: exposureInfo.date,
            duration: exposureInfo.duration,
            totalRiskScore: exposureInfo.totalRiskScore,
            transmissionRiskLevel: exposureInfo.transmissionRiskLevel
        )
    }

    convenience init(
        attenuationDurations: [Double],
        attenuationValue: ENAttenuation,
        date: Date,
        duration: TimeInterval,
        totalRiskScore: ENRiskScore,
        transmissionRiskLevel: ENRiskLevel
    ) {
        self.init()
        self.setValue(attenuationDurations, forKey: "attenuationDurations")
        self.setValue(attenuationValue, forKey: "attenuationValue")
        self.setValue(date, forKey: "date")
        self.setValue(duration, forKey: "duration")
        self.setValue(totalRiskScore, forKey: "totalRiskScore")
        self.setValue(transmissionRiskLevel, forKey: "transmissionRiskLevel")
    }
}
