//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

public protocol DiagnosisServer {
        
    func verifyUniqueTestIdentifier(
        _ identifier: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func postDiagnosisKeys(
        _ diagnosisKeys: [CodableDiagnosisKey],
        completion: @escaping (Error?) -> Void
    ) -> Void
    
    func getDiagnosisKeyFileURLs(
        startingAt index: Int,
        completion: @escaping (Result<[URL], Error>) -> Void
    )
    
    func downloadDiagnosisKeyFile(
        at remoteURL: URL,
        completion: @escaping (Result<[URL], Error>) -> Void
    )
    
    func getExposureConfiguration(
        completion: (Result<ENExposureConfiguration, Error>) -> Void
    )
}
