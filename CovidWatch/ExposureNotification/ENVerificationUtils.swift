//
//  Created by Zsombor Szabo on 05/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import ExposureNotification
import CryptoKit

public class ENVerificationUtils {

    public enum ENVerificationUtilsError: Error {
        case emptyListOfKeys
        case stringEncodingFailure
    }

    // CalculateExposureKeyHMAC will calculate the verification protocol HMAC value.
    // Input keys are already to be base64 encoded. They will be sorted if necessary.
    static func calculateExposureKeyHMAC(
        forTemporaryExposureKeys keys: [ENTemporaryExposureKey],
        secret: Data) throws -> Data {

        guard !keys.isEmpty else {
            throw ENVerificationUtilsError.emptyListOfKeys
        }

        // Sort by the key.
        let sortedKeys = keys.sorted { (lhs, rhs) -> Bool in
            lhs.keyData.base64EncodedString() < rhs.keyData.base64EncodedString()
        }

        // Build the cleartext.
        let perKeyClearText: [String] = sortedKeys.map { key in
            [key.keyData.base64EncodedString(),
             String(key.rollingStartNumber),
             String(key.rollingPeriod),
             String(key.transmissionRiskLevel)].joined(separator: ".")
        }
        let clearText = perKeyClearText.joined(separator: ",")

        guard let clearData = clearText.data(using: .utf8) else {
            throw ENVerificationUtilsError.stringEncodingFailure
        }

        let hmacKey = SymmetricKey(data: secret)
        let authenticationCode = HMAC<SHA256>.authenticationCode(for: clearData, using: hmacKey)
        return authenticationCode.withUnsafeBytes { bytes in
            return Data(bytes)
        }
    }

}
