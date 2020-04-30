//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

// A struct representing the response from the server for a single entry.

public struct PositiveDiagnosis: Codable {
    
    public struct DiagnosisKey: Codable {
        var keyData: Data
        var rollingStartNumber: UInt32
    }
    
    let diagnosisKeys: [DiagnosisKey]
    let publicHealthAuthorityPermissionNumber: String?
    let timestamp: Date? // Set by the server, ignored on upload
}
