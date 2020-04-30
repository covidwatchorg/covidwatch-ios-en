//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

extension ENExposureInfo {
    
    static func makeRandom(timestamp: Date) -> ENExposureInfo {
        let exposureInfo = ENExposureInfo()
        exposureInfo.setValue(UInt8.random(in: 0..<255), forKey: "attenuationValue")
        exposureInfo.setValue(timestamp, forKey: "date")
        exposureInfo.setValue(TimeInterval(Int.random(in: 1..<7) * 5 * 60), forKey: "duration")
        exposureInfo.setValue(ENRiskScore(UInt8.random(in: 0..<100)), forKey: "totalRiskScore")
//        exposureInfo.setValue(ENRiskLevel.high, forKey: "transmissionRiskLevel")
        return exposureInfo
    }
}
