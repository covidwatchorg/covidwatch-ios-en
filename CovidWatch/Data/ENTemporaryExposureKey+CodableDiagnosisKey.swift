//
//  Created by Zsombor Szabo on 30/04/2020.
//

import Foundation
import ExposureNotification

@available(iOS 13.5, *)
extension ENTemporaryExposureKey {
    
    convenience init(_ key: CodableDiagnosisKey) {
        self.init()
        self.keyData = key.keyData
        self.rollingStartNumber = key.rollingStartNumber
        self.transmissionRiskLevel = key.transmissionRiskLevel
    }
}
