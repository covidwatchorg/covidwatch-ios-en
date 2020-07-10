//
//  Created by Zsombor Szabo on 30/06/2020.
//  
//

import Foundation

public protocol ExposureNotificationsDiagnosisVerificationProviding {

    func verifyCode(
        _ code: String,
        completion: @escaping (Result<CodableVerifyCodeResponse, Error>) -> Void
    )

    func getVerificationCertificate(
        forLongTermToken longTermToken: String,
        hmac: String,
        completion: @escaping (Result<CodableVerificationCertificateResponse, Error>) -> Void
    )

}
