//
//  Created by Zsombor Szabo on 30/04/2020.
//

import Foundation
import ExposureNotification

extension CodableDiagnosisKey {
    
    @available(iOS 13.5, *)
    init(_ key: ENTemporaryExposureKey) {
        self.init(
            key: key.keyData,
            rollingPeriod: key.rollingPeriod,
            rollingStartNumber: key.rollingStartNumber,
            transmissionRisk: key.transmissionRiskLevel
        )
    }
}
