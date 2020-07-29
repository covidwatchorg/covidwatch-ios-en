//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

public protocol ExposureNotificationsDiagnosisKeyServing {

    func publishDiagnosisKeys(
        _ diagnosisKeys: [ENTemporaryExposureKey],
        verificationPayload: String?,
        hmacKey: Data?,
        symptomOnsetInterval: ENIntervalNumber,
        revisionToken: String?,
        completion: @escaping (Result<CodablePublishResponse, Error>) -> Void
    )

    func getDiagnosisKeyFileURLs(
        completion: @escaping (Result<[URL], Error>) -> Void
    )

    func downloadDiagnosisKeyFile(
        at remoteURL: URL,
        completion: @escaping (Result<[URL], Error>) -> Void
    )

}
