//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

public let oldestPositiveDiagnosesToFetch: TimeInterval = 60*60*24*7*2

public enum DiagnosisServerError: Error {
    case invalidPublicHealthAuthorityPermissionNumber
}

public protocol DiagnosisServer {
    
    // Note: Server might return URLs pointing to different hosts.
    func getDiagnosisKeyFileURLs(
        startingAt index: Int,
        completion: @escaping (Result<[URL], Error>) -> Void
    )
    
    func downloadDiagnosisKeyFile(
        at remoteURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    )
    
    func getExposureConfiguration(
        completion: @escaping (Result<CodableExposureConfiguration, Error>) -> Void
    )
    
    // On success, server might return a short and user-friendly token.
    // The user can use this token to verify their report with the public health
    // authority (e.g., over the phone).
    func sharePositiveDiagnosis(
        _ positiveDiagnosis: PublishExposure,
        completion: @escaping (Result<String?, Error>) -> Void
    )
    
    // In case the user has a test identifier available at the time of submitting
    // the report.
    func verifyUniqueTestIdentifier(
        _ identifier: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
}
