//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

extension PositiveDiagnosis {
    
    init(keys: [ENTemporaryExposureKey], publicHealthAuthorityPermissionNumber: String) {
        self.diagnosisKeys = keys.map { DiagnosisKey($0) }
        self.publicHealthAuthorityPermissionNumber = publicHealthAuthorityPermissionNumber
        self.timestamp = nil
    }
    
}
