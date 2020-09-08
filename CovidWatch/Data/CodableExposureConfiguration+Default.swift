//
//  Created by Zsombor Szabo on 16/07/2020.
//
//

import Foundation

extension CodableExposureConfiguration {

    #if DEBUG_CALIBRATION
    static let `default`: Self = .init(
        minimumRiskScore: 0,
        attenuationDurationThresholdList: [[30, 33], [33, 36], [36, 39], [39, 42], [42, 45], [45, 48], [48, 51], [51, 54], [54, 57], [57, 60], [60, 63], [63, 66], [66, 69], [69, 72], [72, 75], [75, 78], [78, 81], [81, 84], [84, 87], [87, 90], [90, 93], [93, 96], [96, 99]],
        attenuationLevelValues: [1, 1, 1, 1, 1, 1, 1, 1],
        daysSinceLastExposureLevelValues: [1, 1, 1, 1, 1, 1, 1, 1],
        durationLevelValues: [1, 1, 1, 1, 1, 1, 1, 1],
        transmissionRiskLevelValues: [1, 1, 1, 1, 1, 1, 1, 1]
    )
    #else
    static let `default`: Self = .init(
        minimumRiskScore: 0,
        attenuationDurationThresholds: [50, 70],
        attenuationLevelValues: [0, 1, 1, 1, 1, 1, 1, 1],
        daysSinceLastExposureLevelValues: [1, 1, 1, 1, 1, 1, 1, 1],
        durationLevelValues: [0, 0, 0, 1, 1, 1, 1, 1],
        transmissionRiskLevelValues: [0, 0, 0, 0, 0, 1, 1, 1]
    )
    #endif

}
