//
//  Created by Zsombor Szabo on 23/05/2020.
//  
//

import Foundation
import os.log
import ExposureNotification
import DeviceCheck

public struct GCP {
    static let storageBaseURLString = "https://storage.googleapis.com"
}

public protocol DeviceVerificationPayloadProviding {
    func generatePayload(completionHandler completion: @escaping (Data?, Error?) -> Void)
}

extension DCDevice : DeviceVerificationPayloadProviding {
    public func generatePayload(completionHandler completion: @escaping (Data?, Error?) -> Void) {
        return self.generateToken(completionHandler: completion)
    }
}

public struct AppConfiguration {
    let appPackageName: String = Bundle.main.bundleIdentifier ?? ""
    let platform: String = "iOS"
    let regions: [String]
}

public struct ExportConfiguration {
    let filenameRoot: String
    let bucketName: String
    var indexURLString: String {
        return "\(GCP.storageBaseURLString)/\(bucketName)/\(filenameRoot)/index.txt"
    }
}

@available(iOS 13.5, *)
public class GCPGoogleExposureNotificationServer: GoogleExposureNotificationServer {
    
    public var exposureURLString: String
    public var appConfiguration: AppConfiguration
    public var exportConfiguration: ExportConfiguration
    public var deviceVerificationPayloadProvider = DCDevice.current
    
    init(
        exposureURLString: String,
        appConfiguration: AppConfiguration,
        exportConfiguration: ExportConfiguration
    ) {
        self.exposureURLString = exposureURLString
        self.appConfiguration = appConfiguration
        self.exportConfiguration = exportConfiguration
    }
    
    public override func postDiagnosisKeys(
        _ diagnosisKeys: [CodableDiagnosisKey],
        completion: @escaping (Error?) -> Void
    ) {
        os_log(
            "Posting %d diagnosis key(s) ...",
            log: .cwen,
            diagnosisKeys.count
        )

        self.deviceVerificationPayloadProvider.generatePayload { (token, error) in
            if let error = error {
                os_log(
                    "Posting %d diagnosis key(s) failed=%@",
                    log: .cwen,
                    type: .error,
                    diagnosisKeys.count,
                    error as CVarArg
                )
                completion(error)
                return
            }
            
//            let shiftedDiagnosisKeys: [CodableDiagnosisKey] = diagnosisKeys.map {
//                CodableDiagnosisKey(
//                    keyData: $0.keyData,
//                    rollingPeriod: $0.rollingPeriod,
//                    rollingStartNumber: $0.rollingStartNumber - 144,
//                    transmissionRiskLevel: $0.transmissionRiskLevel
//                )
//            }

            let publishExposure = PublishExposure(
                temporaryExposureKeys: diagnosisKeys,
//                temporaryExposureKeys: shiftedDiagnosisKeys,
                regions: self.appConfiguration.regions,
                appPackageName: self.appConfiguration.appPackageName,
                platform: self.appConfiguration.platform,
                deviceVerificationPayload: token!.base64EncodedString(),
                verificationPayload: "signature /code from  of verifying authority",
                padding: Data.random(count: Int.random(in: 1024..<2048)).base64EncodedString()
            )

            guard let requestURL = URL(string: self.exposureURLString) else {
                completion(URLError(.badURL))
                return
            }
            
            var uploadData: Data!
            do {
                let encoder = JSONEncoder()
                encoder.dataEncodingStrategy = .base64
                uploadData = try encoder.encode(publishExposure)
            } catch {
                completion(error)
                return
            }

            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.uploadTask(
                with: request,
                from: uploadData
            ) { (result) in
                switch result {
                    case .failure(let error):
                        os_log(
                            "Posting %d diagnosis key(s) failed=%@",
                            log: .cwen,
                            type: .error,
                            diagnosisKeys.count,
                            error as CVarArg
                        )
                        completion(error)
                        return

                    case .success(_):
                        os_log(
                            "Posted %d diagnosis key(s)",
                            log: .cwen,
                            diagnosisKeys.count
                        )
                        completion(nil)
                        return
                }
            }
            task.resume()
        }
    }
    
    public override func getDiagnosisKeyFileURLs(
        startingAt index: Int,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        os_log(
            "Getting diagnosis key file URLs starting at index=%d ...",
            log: .cwen,
            index
        )
        
        guard let requestURL = URL(string: self.exportConfiguration.indexURLString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let request = URLRequest(url: requestURL)

        URLSession.shared.dataTask(with: request) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Getting diagnosis key file URLs starting at index=%d failed=%@ ...",
                        log: .cwen,
                        type: .error,
                        index,
                        error as CVarArg
                    )
                    completion(.failure(error))
                    return

                case .success(let (_, data)):
                    do {
                        guard let dataString = String(bytes: data, encoding: .utf8) else {
                            throw CocoaError(.coderInvalidValue)
                        }
                        let entries = dataString.split(separator: "\n")
                        let keyFileURLs: [URL] = entries.compactMap {
                            URL(string: "\(GCP.storageBaseURLString)/\(self.exportConfiguration.bucketName)/\($0)")
                        }
                        // TODO: Figure out if dropping the first index results is the way to go. Returning everything, for now.
                        //let result = Array(keyFileURLs.dropFirst(index))
                        let result = keyFileURLs
                        os_log(
                            "Got diagnosis key file URLs starting at index=%d count=%d",
                            log: .cwen,
                            index,
                            result.count
                        )
                        completion(.success(result))
                    }
                    catch {
                        os_log(
                            "Getting diagnosis key file URLs starting at index=%d failed=%@ ...",
                            log: .cwen,
                            type: .error,
                            index,
                            error as CVarArg
                        )
                        completion(.failure(error))
                    }
                    return
            }
        }.resume()
    }

}
