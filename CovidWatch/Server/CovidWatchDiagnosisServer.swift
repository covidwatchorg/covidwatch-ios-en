//
//  Created by Zsombor Szabo on 28/04/2020.
//

import Foundation
import os.log
import ExposureNotification
import DeviceCheck
import ZIPFoundation

public struct PublishExposure: Codable {
    let temporaryExposureKeys: [CodableDiagnosisKey]
    let regions: [String]
    let appPackageName: String
    let platform: String
    let deviceVerificationPayload: String
    let verificationPayload: String
    let padding: String
}


@available(iOS 13.5, *)
public class CovidWatchDiagnosisServer: DiagnosisServer {
    
    public let configuration: DiagnosisServerConfiguration
    
    public required init(configuration: DiagnosisServerConfiguration) {
        self.configuration = configuration
    }
    
    // TODO
    public func verifyUniqueTestIdentifier(
        _ identifier: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        os_log(
            "Verifying unique test identifier=%@ ...",
            log: .cwen,
            identifier
        )
        
        let fetchUrl = URL(string: "\(self.configuration.apiUrlString)/verifyUniqueTestIdentifier") ??
            URL(fileURLWithPath: "")
        
        let request = URLRequest(url: fetchUrl)
        
        URLSession.shared.dataTask(with: request) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Verifying unique test identifier=%@ failed=%@ ...",
                        log: .cwen,
                        type: .error,
                        identifier,
                        error as CVarArg
                    )
                    completion(.failure(error))
                    return
                
                case .success(let (response, _)):
                    os_log(
                        "Verified unique test identifier=%@ response=%@",
                        log: .cwen,
                        identifier,
                        response.description
                    )
                    completion(.success(true))
                    return
            }
        }.resume()
    }
    
    public func postDiagnosisKeys(
        _ diagnosisKeys: [CodableDiagnosisKey],
        completion: @escaping (Error?) -> Void
    ) {
        os_log(
            "Posting %d diagnosis key(s) ...",
            log: .cwen,
            diagnosisKeys.count
        )
        
        DCDevice.current.generateToken { (token, error) in
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
            
            let publishExposure = PublishExposure(
                temporaryExposureKeys: diagnosisKeys,
                regions: self.configuration.regions,
                appPackageName: Bundle.main.bundleIdentifier!,
                platform: "ios",
                deviceVerificationPayload: token!.base64EncodedString(),
                verificationPayload: "signature /code from  of verifying authority",
                padding: Data.random(count: Int.random(in: 1024..<2048)).base64EncodedString()
            )
                        
            let requestURL = URL(string: self.configuration.apiExposureURLString) ?? URL(fileURLWithPath: "")

            let encoder = JSONEncoder()
            encoder.dataEncodingStrategy = .base64

            var uploadData: Data! = try? encoder.encode(publishExposure)
            if uploadData == nil {
                uploadData = Data()
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
    
    // TODO
    public func getDiagnosisKeyFileURLs(
        startingAt index: Int,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        os_log(
            "Getting diagnosis key file URLs starting at index=%d ...",
            log: .cwen,
            index
        )
        
        let fetchUrl = URL(string: "\(self.configuration.apiUrlString)/getDiagnosisKeyFileURLs?startingAt=\(index)") ??
            URL(fileURLWithPath: "")
        
        let request = URLRequest(url: fetchUrl)
        
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
                
                case .success(let (response, data)):
                    do {
                        let decoder = JSONDecoder()
                        let diagnosisKeyFileURLs = try decoder.decode(
                            [URL].self,
                            from: data
                        )
                        os_log(
                            "Got diagnosis key file URLs starting at index=%d response=%@",
                            log: .cwen,
                            index,
                            response.description
                        )
                        completion(.success(diagnosisKeyFileURLs))
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
    
    public func downloadDiagnosisKeyFile(
        at remoteURL: URL,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        os_log(
            "Downloading diagnosis key file at remote URL=%@ ...",
            log: .cwen,
            remoteURL.description
        )
        
        let request = URLRequest(url: remoteURL)
        
        URLSession.shared.downloadTask(with: request) { (url, response, error) in
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
                
                os_log(
                    "Downloaded diagnosis key file at remote URL=%@ to=%@",
                    log: .cwen,
                    remoteURL.description,
                    zipFileContentURLs.description
                )
                completion(.success(zipFileContentURLs))
            } catch {
                os_log(
                    "Downloading diagnosis key file at remote URL=%@ failed=%@ ...",
                    log: .cwen,
                    type: .error,
                    remoteURL.description,
                    error as CVarArg
                )
                completion(.failure(error))
            }
        }.resume()
    }
    
    // TODO
    public func getExposureConfiguration(
        completion: @escaping (Result<CodableExposureConfiguration, Error>) -> Void
    ) {
        os_log(
            "Getting exposure configuration ...",
            log: .cwen
        )
        
        let fetchUrl = URL(string: "\(self.configuration.apiUrlString)/getExposureConfiguration") ??
            URL(fileURLWithPath: "")
        
        let request = URLRequest(url: fetchUrl)
        
        URLSession.shared.dataTask(with: request) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Getting exposure configuration failed=%@ ...",
                        log: .cwen,
                        type: .error,
                        error as CVarArg
                    )
                    completion(.failure(error))
                    return
                
                case .success(let (response, data)):
                    do {
                        let decoder = JSONDecoder()
                        let codableExposureConfiguration = try decoder.decode(
                            CodableExposureConfiguration.self,
                            from: data
                        )
                        os_log(
                            "Got exposure configuration response=%@",
                            log: .cwen,
                            response.description
                        )
                        completion(.success(codableExposureConfiguration))
                    }
                    catch {
                        os_log(
                            "Getting exposure configuration failed=%@ ...",
                            log: .cwen,
                            type: .error,
                            error as CVarArg
                        )
                        completion(.failure(error))
                    }
                    return
            }
        }.resume()
    }
}
