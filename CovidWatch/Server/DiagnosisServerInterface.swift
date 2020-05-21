//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

public struct DiagnosisServerConfiguration {
    
    let apiUrlString: String
    let apiExposureURLString: String
    let regions: [String]
}

public protocol DiagnosisServer {
        
    var configuration: DiagnosisServerConfiguration { get }
    
    init(configuration: DiagnosisServerConfiguration)
    
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
        completion: @escaping (Result<CodableExposureConfiguration, Error>) -> Void
    )
}
