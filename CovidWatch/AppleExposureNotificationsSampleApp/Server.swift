/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A class representing a local server that vends exposure data.
 */

import Foundation
import ExposureNotification
import SwiftProtobuf

@available(iOS 13.5, *)
public class Server {

    public init() {}

    public static let shared = Server()

    public var keyServer: ExposureNotificationsDiagnosisKeyServing?
    public var verificationServer: ExposureNotificationsDiagnosisVerificationProviding?

    func postDiagnosisKeys(
        _ diagnosisKeys: [ENTemporaryExposureKey],
        verificationPayload: String? = nil,
        hmacKey: Data? = nil,
        completion: @escaping (Error?
        ) -> Void) {

        if let diagnosisServer = self.keyServer {

            diagnosisServer.postDiagnosisKeys(
                diagnosisKeys,
                verificationPayload: verificationPayload,
                hmacKey: hmacKey,
                completion: completion
            )
        } else {
            completion(CocoaError(.fileNoSuchFile))
        }
    }

    func getDiagnosisKeyFileURLs(completion: @escaping (Result<[URL], Error>) -> Void) {

        if let diagnosisServer = self.keyServer {

            diagnosisServer.getDiagnosisKeyFileURLs(
                completion: completion
            )
        } else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }

    // The URL passed to the completion is the local URL of the downloaded diagnosis key file
    func downloadDiagnosisKeyFile(at remoteURL: URL, completion: @escaping (Result<[URL], Error>) -> Void) {

        if let diagnosisServer = self.keyServer {

            diagnosisServer.downloadDiagnosisKeyFile(
                at: remoteURL,
                completion: completion
            )
        } else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }

    func deleteDiagnosisKeyFile(at localURLs: [URL]) throws {
        for localURL in localURLs {
            try FileManager.default.removeItem(at: localURL)
        }
    }

    func getExposureConfiguration(completion: @escaping (Result<ENExposureConfiguration, Error>) -> Void) {

        if let diagnosisServer = self.keyServer {

            diagnosisServer.getExposureConfiguration(completion: completion)
        } else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }

    #if DEBUG_CALIBRATION
    func getExposureConfigurationList(completion: @escaping (Result<[ENExposureConfiguration], Error>) -> Void) {

        if let keyServer = self.keyServer {

            keyServer.getExposureConfigurationList(completion: completion)
        } else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    #endif

    func verifyCode(_ code: String, completion: @escaping (Result<CodableVerifyCodeResponse, Error>) -> Void) {

        // In a real implementation, this identifer would be validated on a server
        if let verificationServer = self.verificationServer {

            verificationServer.verifyCode(
                code,
                completion: completion
            )
        } else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }

    func getVerificationCertificate(
        forLongTermToken longTermToken: String,
        hmac: String,
        completion: @escaping (Result<CodableVerificationCertificateResponse, Error>) -> Void
    ) {
        if let verificationServer = self.verificationServer {

            verificationServer.getVerificationCertificate(
                forLongTermToken: longTermToken,
                hmac: hmac,
                completion: completion
            )
        } else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
}
