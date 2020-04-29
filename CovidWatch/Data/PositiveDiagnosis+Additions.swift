//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension PositiveDiagnosis {
    
    init(keys: [ENTemporaryExposureKey], publicHealthAuthorityPermissionNumber: String) {
        self.diagnosisKeys = keys.map {
            DiagnosisKey(keyData: $0.keyData, rollingStartNumber: UInt32($0.rollingStartNumber))
        }
        self.publicHealthAuthorityPermissionNumber = publicHealthAuthorityPermissionNumber
        self.timestamp = nil
    }
    
}
