//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

// A struct representing the response from the server for a single entry.
public struct PositiveDiagnosis: Codable {
    
    public struct DiagnosisKey: Codable {
        var keyData: Data
        var rollingStartNumber: UInt32
        var transmissionRiskLevel: UInt8
    }
    
    let diagnosisKeys: [DiagnosisKey]
    let publicHealthAuthorityPermissionNumber: String?
    let timestamp: Date? // Set by the server, ignored on upload
}

extension PositiveDiagnosis.DiagnosisKey {
    
    init(_ key: ENTemporaryExposureKey) {
        self.init(keyData: key.keyData, rollingStartNumber: key.rollingStartNumber, transmissionRiskLevel: key.transmissionRiskLevel.rawValue)
    }
}

extension ENTemporaryExposureKey {
    
    convenience init(_ key: PositiveDiagnosis.DiagnosisKey) {
        self.init()
        self.keyData = key.keyData
        self.rollingStartNumber = key.rollingStartNumber
        self.transmissionRiskLevel = ENRiskLevel(rawValue: key.transmissionRiskLevel) ?? .invalid
    }
}
