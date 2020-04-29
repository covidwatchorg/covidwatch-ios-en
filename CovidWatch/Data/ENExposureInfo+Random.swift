//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension ENExposureInfo {
    
    static func makeRandom(timestamp: Date) -> ENExposureInfo {
        return ENExposureInfo(
            attenuationValue: UInt8.random(in: 0..<255),
            date: timestamp,
            duration: TimeInterval(Int.random(in: 0..<7) * 5 * 60)
        )
    }
}
