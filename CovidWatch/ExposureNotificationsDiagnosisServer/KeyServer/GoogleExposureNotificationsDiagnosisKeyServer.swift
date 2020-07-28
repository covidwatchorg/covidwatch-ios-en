//
//  Created by Zsombor Szabo on 28/04/2020.
//

import Foundation
import os.log
import ExposureNotification
import DeviceCheck
import ZIPFoundation
import Combine

public struct GoogleCloudPlatform {
    static let cloudStorageBaseURLString = "https://storage.googleapis.com"
}

@available(iOS 13.6, *)
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

    public enum ServerError: Error, LocalizedError {

        case serverSideError(String)

        public var errorDescription: String? {
            switch self {
                case .serverSideError(let errorMessage):
                    return errorMessage
            }
        }
    }

    public var configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    public func postDiagnosisKeys(
        _ diagnosisKeys: [ENTemporaryExposureKey],
        verificationPayload: String? = nil,
        hmacKey: Data? = nil,
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
            verificationPayload: verificationPayload ?? "",
            hmackey: hmacKey?.base64EncodedString() ?? "",
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

        request.httpBody = uploadData

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw ServerError.serverSideError(String(bytes: element.data, encoding: .utf8) ?? "")
                }
                return element.data
        }
        .receive(on: DispatchQueue.main)
        .receive(subscriber: Subscribers.Sink(receiveCompletion: { (sinkCompletion) in
            switch sinkCompletion {
                case .failure(let error):
                    os_log(
                        "Posting %d diagnosis key(s) failed=%@",
                        log: .en,
                        type: .error,
                        diagnosisKeys.count,
                        error as CVarArg
                    )
                    completion(error)
                case .finished: ()
            }
        }, receiveValue: { (_) in
            os_log(
                "Posted %d diagnosis key(s)",
                log: .en,
                diagnosisKeys.count
            )
            completion(nil)
        }))
    }

    public func getDiagnosisKeyFileURLs(
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        guard let requestURL = URL(string: self.configuration.exportConfiguration.indexURLString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        os_log(
            "Getting diagnosis key file URLs from URL=%@...",
            log: .en,
            requestURL.absoluteString
        )

        let request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, _) -> [URL] in
                // Data is a plain text file and each line contains an entry for a ZIP file stored in the bucket
                guard let dataString = String(bytes: data, encoding: .utf8) else {
                    throw URLError(.badServerResponse)
                }
                let entries = dataString.split(separator: "\n")
                let keyFileURLs: [URL] = entries.compactMap {
                    URL(string: "\(GoogleCloudPlatform.cloudStorageBaseURLString)/\(self.configuration.exportConfiguration.cloudStorageBucketName)/\($0)")
                }
                return keyFileURLs
            }
            .receive(on: DispatchQueue.main)
            .receive(subscriber: Subscribers.Sink(receiveCompletion: { (sinkCompletion) in
                switch sinkCompletion {
                    case .failure(let error):
                        os_log(
                            "Getting diagnosis key file URLs failed=%@ ...",
                            log: .en,
                            type: .error,
                            error as CVarArg
                        )
                        completion(.failure(error))
                    case .finished: ()
                }
            }, receiveValue: { (value) in
                os_log(
                    "Got diagnosis key file URLs count=%d",
                    log: .en,
                    value.count
                )
                completion(.success(value))
            }))
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

                let uuidString = UUID().uuidString
                let unzipDestinationDirectory = cachesDirectoryURL.appendingPathComponent(uuidString)
                try FileManager.default.createDirectory(at: unzipDestinationDirectory, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.unzipItem(at: savedURL, to: unzipDestinationDirectory)
                try FileManager.default.removeItem(at: savedURL)
                let zipFileContentURLs = try FileManager.default.contentsOfDirectory(at: unzipDestinationDirectory, includingPropertiesForKeys: nil)
                var uniqueNameZipFileContentURLs = [URL]()
                for url in zipFileContentURLs {
                    let newUrlLastPathComponent = uuidString + "-" + url.lastPathComponent
                    let newUrl = unzipDestinationDirectory.appendingPathComponent(newUrlLastPathComponent)
                    try FileManager.default.moveItem(at: url, to: newUrl)
                    uniqueNameZipFileContentURLs.append(newUrl)
                }
                let result = uniqueNameZipFileContentURLs

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

}
