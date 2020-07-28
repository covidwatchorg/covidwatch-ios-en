//
//  Created by Zsombor Szabo on 01/07/2020.
//  
//

import Foundation
import os.log
import Combine

@available(iOS 13.6, *)
public class GoogleExposureNotificationsDiagnosisVerificationServer: ExposureNotificationsDiagnosisVerificationProviding {

    public struct Configuration {
        let apiServerBaseURLString: String
        let apiKey: String
    }

    public var configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    public enum ServerError: Error, LocalizedError {

        case serverSideError(String)

        public var errorDescription: String? {
            switch self {
                case .serverSideError(let errorMessage):
                    return errorMessage
            }
        }
    }

    public func verifyCode(
        _ code: String,
        completion: @escaping (Result<CodableVerifyCodeResponse, Error>) -> Void
    ) {
        os_log(
            "Verifying code=%@ ...",
            log: .en,
            code
        )

        guard let url = URL(string: "\(self.configuration.apiServerBaseURLString)/api/verify") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let codableVerifyCodeRequest = CodableVerifyCodeRequest(code: code)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.configuration.apiKey, forHTTPHeaderField: "X-API-Key")

        var uploadData: Data!
        do {
            let encoder = JSONEncoder()
            encoder.dataEncodingStrategy = .base64
            uploadData = try encoder.encode(codableVerifyCodeRequest)
        } catch {
            completion(.failure(error))
            return
        }

        request.httpBody = uploadData

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        if let errorResponse = try? JSONDecoder().decode(CodableErrorReturn.self, from: element.data) {
                            throw ServerError.serverSideError(errorResponse.error)
                        }
                        if let message = String(bytes: element.data, encoding: .utf8) {
                            throw ServerError.serverSideError(message)
                        }
                        throw URLError(.badServerResponse)
                }
                return element.data
        }
        .decode(type: CodableVerifyCodeResponse.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .receive(subscriber: Subscribers.Sink(receiveCompletion: { (sinkCompletion) in
            switch sinkCompletion {
                case .failure(let error):
                    os_log(
                        "Verifying code=%@ failed=%@",
                        log: .en,
                        type: .error,
                        code,
                        error as CVarArg
                    )
                    completion(.failure(error))
                case .finished: ()
            }
        }, receiveValue: { (value) in
            os_log(
                "Verified code=%@ response=%@",
                log: .en,
                code,
                String(describing: value)
            )
            completion(.success(value))
        }))
    }

    public func getVerificationCertificate(
        forLongTermToken longTermToken: String,
        hmac: String,
        completion: @escaping (Result<CodableVerificationCertificateResponse, Error>) -> Void
    ) {
        os_log(
            "Requesting verification certificate for long-term token=%@ hmac=%@ ...",
            log: .en,
            longTermToken,
            hmac
        )

        guard let url = URL(string: "\(self.configuration.apiServerBaseURLString)/api/certificate") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let codableRequest = CodableVerificationCertificateRequest(token: longTermToken, hmac: hmac)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.configuration.apiKey, forHTTPHeaderField: "X-API-Key")

        var uploadData: Data!
        do {
            let encoder = JSONEncoder()
            encoder.dataEncodingStrategy = .base64
            uploadData = try encoder.encode(codableRequest)
        } catch {
            completion(.failure(error))
            return
        }

        request.httpBody = uploadData

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        if let errorResponse = try? JSONDecoder().decode(CodableErrorReturn.self, from: element.data) {
                            throw ServerError.serverSideError(errorResponse.error)
                        }
                        if let message = String(bytes: element.data, encoding: .utf8) {
                            throw ServerError.serverSideError(message)
                        }
                        throw URLError(.badServerResponse)
                }
                return element.data
        }
        .decode(type: CodableVerificationCertificateResponse.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .receive(subscriber: Subscribers.Sink(receiveCompletion: { (sinkCompletion) in
            switch sinkCompletion {
                case .failure(let error):
                    os_log(
                        "Requesting verification certificate for long-term token=%@ hmac=%@ failed=%@...",
                        log: .en,
                        type: .error,
                        longTermToken,
                        hmac,
                        error as CVarArg
                    )
                    completion(.failure(error))
                case .finished: ()
            }
        }, receiveValue: { (value) in
            os_log(
                "Requested verification certificate for long-term token=%@ hmac=%@ response=%@",
                log: .en,
                longTermToken,
                hmac,
                String(describing: value)
            )
            completion(.success(value))
        }))
    }

}
