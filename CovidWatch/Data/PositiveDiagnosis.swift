//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation

public struct PositiveDiagnosis: Codable {
        
    let diagnosisKeys: [CodableDiagnosisKey]
    
    let publicHealthAuthorityPermissionNumber: String?
    
    let timestamp: Date? // Set by the server, ignored on upload
}
