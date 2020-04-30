//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation

extension PositiveDiagnosis {
    
    static func makeRandom(timestamp: Date) -> PositiveDiagnosis {
        let intervalNumber = UInt32(timestamp.timeIntervalSince1970 / (60 * 10))
        let diagnosisKeys: [DiagnosisKey] = (0..<14).map { index in
            return DiagnosisKey(
                keyData: Data.random(count: 16),
                rollingStartNumber: intervalNumber - UInt32((144 * index)),
                transmissionRiskLevel: UInt8.random(in: 0..<100)
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
