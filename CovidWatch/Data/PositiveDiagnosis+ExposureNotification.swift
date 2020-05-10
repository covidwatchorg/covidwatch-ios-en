//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

extension PositiveDiagnosis {
    
    @available(iOS 13.5, *)
    init(
        temporaryExposureKeys: [ENTemporaryExposureKey],
        publicHealthAuthorityPermissionNumber: String
    ) {
        self.diagnosisKeys = temporaryExposureKeys.map { CodableDiagnosisKey($0) }
        self.publicHealthAuthorityPermissionNumber = publicHealthAuthorityPermissionNumber
        self.timestamp = nil
    }
}
