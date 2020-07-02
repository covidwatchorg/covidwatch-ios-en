//
//  Created by Zsombor Szabo on 28/04/2020.
//

import Foundation
import os.log
import ExposureNotification
import DeviceCheck
import ZIPFoundation

public struct GoogleCloudPlatform {
    static let cloudStorageBaseURLString = "https://storage.googleapis.com"
}

@available(iOS 13.5, *)
public class GoogleExposureNotificationsDiagnosisKeyServer: ExposureNotificationsDiagnosisKeyServing {

    public struct Configuration {
        let exposureBaseURLString: String
        let appConfiguration: AppConfiguration
        let exportConfiguration: ExportConfiguration
    }

    public struct AppConfiguration {
        let appPackageName: String = Bundle.main.bundleIdentifier ?? ""
        let regions: [String]
    }

    public struct ExportConfiguration {
        let cloudStorageBucketName: String
        let filenameRoot: String
        var indexURLString: String {
            return "\(GoogleCloudPlatform.cloudStorageBaseURLString)/\(cloudStorageBucketName)/\(filenameRoot)/index.txt"
        }
    }

    public var configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    public func postDiagnosisKeys(
        _ diagnosisKeys: [ENTemporaryExposureKey],
        completion: @escaping (Error?) -> Void
    ) {
        os_log(
            "Posting %d diagnosis key(s) ...",
            log: .en,
            diagnosisKeys.count
        )

        let codableDiagnosisKeys = diagnosisKeys.compactMap { diagnosisKey -> CodableDiagnosisKey? in
            return CodableDiagnosisKey(
                keyData: diagnosisKey.keyData,
                rollingPeriod: diagnosisKey.rollingPeriod,
                rollingStartNumber: diagnosisKey.rollingStartNumber,
                transmissionRiskLevel: diagnosisKey.transmissionRiskLevel
            )
        }

        let publishExposure = CodablePublishExposure(
            temporaryExposureKeys: codableDiagnosisKeys,
            regions: self.configuration.appConfiguration.regions,
            appPackageName: self.configuration.appConfiguration.appPackageName,
            verificationPayload: "signed JWT issued by public health authority",
            hmackey: "base64 encoded HMAC key used in preparing the data for the verification server",
            padding: Data.random(count: Int.random(in: 1024..<2048)).base64EncodedString()
        )

        guard let requestURL = URL(string: self.configuration.exposureBaseURLString) else {
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
                        log: .en,
                        type: .error,
                        diagnosisKeys.count,
                        error as CVarArg
                    )
                    completion(error)
                    return

                case .success:
                    os_log(
                        "Posted %d diagnosis key(s)",
                        log: .en,
                        diagnosisKeys.count
                    )
                    completion(nil)
                    return
            }
        }
        task.resume()
    }

    public func getDiagnosisKeyFileURLs(
        startingAt index: Int,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        os_log(
            "Getting diagnosis key file URLs starting at index=%d ...",
            log: .en,
            index
        )

        guard let requestURL = URL(string: self.configuration.exportConfiguration.indexURLString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let request = URLRequest(url: requestURL)

        URLSession.shared.dataTask(with: request) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Getting diagnosis key file URLs starting at index=%d failed=%@ ...",
                        log: .en,
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
                            URL(string: "\(GoogleCloudPlatform.cloudStorageBaseURLString)/\(self.configuration.exportConfiguration.cloudStorageBucketName)/\($0)")
                        }
                        // TODO: Figure out if dropping the first index results is the way to go. Returning everything, for now.
                        //let result = Array(keyFileURLs.dropFirst(index))
                        let result = keyFileURLs
                        os_log(
                            "Got diagnosis key file URLs starting at index=%d count=%d",
                            log: .en,
                            index,
                            result.count
                        )
                        completion(.success(result))
                    } catch {
                        os_log(
                            "Getting diagnosis key file URLs starting at index=%d failed=%@ ...",
                            log: .en,
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

    public func downloadDiagnosisKeyFile(
        at remoteURL: URL,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        os_log(
            "Downloading diagnosis key file at remote URL=%@ ...",
            log: .en,
            remoteURL.description
        )

        let request = URLRequest(url: remoteURL)

        URLSession.shared.downloadTask(with: request) { (url, _, error) in
            do {
                if let error = error {
                    throw(error)
                }
                guard let url = url,
                    let cachesDirectoryURL = FileManager.default.urls(
                        for: .cachesDirectory,
                        in: .userDomainMask
                    ).first else {

                        throw(CocoaError(.fileNoSuchFile))
                }

                let savedURL = cachesDirectoryURL.appendingPathComponent(
                    url.lastPathComponent
                )

                try FileManager.default.moveItem(at: url, to: savedURL)

                let unzipDestinationDirectory = cachesDirectoryURL.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: unzipDestinationDirectory, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.unzipItem(at: savedURL, to: unzipDestinationDirectory)
                try FileManager.default.removeItem(at: savedURL)
                let zipFileContentURLs = try FileManager.default.contentsOfDirectory(at: unzipDestinationDirectory, includingPropertiesForKeys: nil)
                let filteredZIPFileContentURLs = zipFileContentURLs.filter { (url) -> Bool in
                    let size: UInt64 = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? UInt64) ?? 0
                    return size != 0
                }
                let result = filteredZIPFileContentURLs

                os_log(
                    "Downloaded diagnosis key file at remote URL=%@ to local URL count=%d",
                    log: .en,
                    remoteURL.description,
                    result.count
                )
                completion(.success(result))
            } catch {
                os_log(
                    "Downloading diagnosis key file at remote URL=%@ failed=%@ ...",
                    log: .en,
                    type: .error,
                    remoteURL.description,
                    error as CVarArg
                )
                completion(.failure(error))
            }
        }.resume()
    }

    // TODO
    public func getExposureConfiguration(completion: (Result<ENExposureConfiguration, Error>) -> Void) {
        os_log(
            "Getting exposure configuration from server ...",
            log: .en
        )

        let dataFromServer = LocalStore.shared.exposureConfiguration.data(using: .utf8)!

        do {
            let codableExposureConfiguration = try JSONDecoder().decode(CodableExposureConfiguration.self, from: dataFromServer)
            let exposureConfiguration = ENExposureConfiguration()

            exposureConfiguration.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
            exposureConfiguration.attenuationLevelValues = codableExposureConfiguration.attenuationLevelValues as [NSNumber]
            exposureConfiguration.daysSinceLastExposureLevelValues = codableExposureConfiguration.daysSinceLastExposureLevelValues as [NSNumber]
            exposureConfiguration.durationLevelValues = codableExposureConfiguration.durationLevelValues as [NSNumber]
            exposureConfiguration.transmissionRiskLevelValues = codableExposureConfiguration.transmissionRiskLevelValues as [NSNumber]
            #if DEBUG_CALIBRATION
            exposureConfiguration.setValue(codableExposureConfiguration.attenuationDurationThresholdList[0], forKey: "attenuationDurationThresholds")
            #else
            exposureConfiguration.setValue(codableExposureConfiguration.attenuationDurationThresholds, forKey: "attenuationDurationThresholds")
            #endif

            os_log(
                "Got exposure configuration=%@ from server",
                log: .en,
                exposureConfiguration.description
            )

            completion(.success(exposureConfiguration))
        } catch {
            os_log(
                "Getting exposure configuration from server failed=%@",
                log: .en,
                type: .error,
                error as CVarArg
            )
            completion(.failure(error))
        }

//        os_log(
//            "Getting exposure configuration ...",
//            log: .en
//        )
//        
//        let fetchUrl = URL(string: "\(self.configuration.apiUrlString)/getExposureConfiguration") ??
//            URL(fileURLWithPath: "")
//        
//        let request = URLRequest(url: fetchUrl)
//        
//        URLSession.shared.dataTask(with: request) { (result) in
//            switch result {
//                case .failure(let error):
//                    os_log(
//                        "Getting exposure configuration failed=%@ ...",
//                        log: .en,
//                        type: .error,
//                        error as CVarArg
//                    )
//                    completion(.failure(error))
//                    return
//                
//                case .success(let (response, data)):
//                    do {
//                        let decoder = JSONDecoder()
//                        let codableExposureConfiguration = try decoder.decode(
//                            CodableExposureConfiguration.self,
//                            from: data
//                        )
//                        os_log(
//                            "Got exposure configuration response=%@",
//                            log: .en,
//                            response.description
//                        )
//                        completion(.success(codableExposureConfiguration))
//                    }
//                    catch {
//                        os_log(
//                            "Getting exposure configuration failed=%@ ...",
//                            log: .en,
//                            type: .error,
//                            error as CVarArg
//                        )
//                        completion(.failure(error))
//                    }
//                    return
//            }
//        }.resume()
    }

}
