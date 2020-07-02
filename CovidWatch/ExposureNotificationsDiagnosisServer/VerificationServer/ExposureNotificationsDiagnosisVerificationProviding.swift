//
//  Created by Zsombor Szabo on 30/06/2020.
//  
//

import Foundation

public protocol ExposureNotificationsDiagnosisVerificationProviding {
        
    func verifyUniqueTestIdentifier(
        _ identifier: String,
        completion: @escaping (Result<String, Error>) -> Void
    )

}
