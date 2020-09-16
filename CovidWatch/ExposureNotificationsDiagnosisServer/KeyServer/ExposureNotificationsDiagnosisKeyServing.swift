//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import ExposureNotification

public protocol ExposureNotificationsDiagnosisKeyServing {

    func postDiagnosisKeys(
        _ diagnosisKeys: [ENTemporaryExposureKey],
        verificationPayload: String?,
        hmacKey: Data?,
        completion: @escaping (Error?) -> Void
    )

    func getDiagnosisKeyFileURLs(
        completion: @escaping (Result<[URL], Error>) -> Void
    )

    func downloadDiagnosisKeyFile(
        at remoteURL: URL,
        completion: @escaping (Result<[URL], Error>) -> Void
    )

}
