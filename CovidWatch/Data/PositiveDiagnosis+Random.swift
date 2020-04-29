//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension PositiveDiagnosis {
    
    static func makeRandom(timestamp: Date) -> PositiveDiagnosis {
        let intervalNumber = UInt32(timestamp.timeIntervalSince1970 / (60 * 10))
        let diagnosisKeys: [DiagnosisKey] = (0..<14).map { index in
            return DiagnosisKey(
                keyData: Data.random(count: 16),
                rollingStartNumber: intervalNumber - UInt32((144 * index))
            )
        }
        return PositiveDiagnosis(
            diagnosisKeys: diagnosisKeys,
            publicHealthAuthorityPermissionNumber:
            String.random(count: 16),
            timestamp: timestamp
        )
    }
    
}
