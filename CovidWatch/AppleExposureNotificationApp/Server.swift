/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A class representing a local server that vends exposure data.
 */

import Foundation
import ExposureNotification
import SwiftProtobuf

public struct CodableDiagnosisKey: Codable, Equatable {
    let keyData: Data
    let rollingPeriod: ENIntervalNumber
    let rollingStartNumber: ENIntervalNumber
    let transmissionRiskLevel: ENRiskLevel
}

public struct CodableExposureConfiguration: Codable {
    let minimumRiskScore: ENRiskScore
    let attenuationLevelValues: [ENRiskLevelValue]
    let attenuationWeight: Double
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureWeight: Double
    let durationLevelValues: [ENRiskLevelValue]
    let durationWeight: Double
    let transmissionRiskLevelValues: [ENRiskLevelValue]
    let transmissionRiskWeight: Double
}

@available(iOS 13.5, *)
public class Server {
    
    public init() {}
    
    public static let shared = Server()
    
    public var diagnosisServer: DiagnosisServer?
    
    func postDiagnosisKeys(_ diagnosisKeys: [ENTemporaryExposureKey], completion: @escaping (Result<String?, Error>) -> Void) {
        
        // Convert keys to something that can be encoded to JSON and upload them.
        let codableDiagnosisKeys = diagnosisKeys.compactMap { diagnosisKey -> CodableDiagnosisKey? in
            return CodableDiagnosisKey(keyData: diagnosisKey.keyData,
                                       rollingPeriod: diagnosisKey.rollingPeriod,
                                       rollingStartNumber: diagnosisKey.rollingStartNumber,
                                       transmissionRiskLevel: diagnosisKey.transmissionRiskLevel)
        }
        
        // Your server needs to handle de-duplicating keys.
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.sharePositiveDiagnosis(
                PositiveDiagnosis(
                    diagnosisKeys: codableDiagnosisKeys,
                    publicHealthAuthorityPermissionNumber: nil,
                    timestamp: nil),
                completion: completion)
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    
    func getDiagnosisKeyFileURLs(startingAt index: Int, completion: @escaping (Result<[URL], Error>) -> Void) {
        
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.getDiagnosisKeyFileURLs(
                startingAt: index,
                completion: completion
            )
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    
    // The URL passed to the completion is the local URL of the downloaded diagnosis key file
    func downloadDiagnosisKeyFile(at remoteURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.downloadDiagnosisKeyFile(
                at: remoteURL,
                completion: completion
            )
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    
    func deleteDiagnosisKeyFile(at localURL: URL) throws {
        try FileManager.default.removeItem(at: localURL)
    }
    
    func getExposureConfiguration(completion: @escaping (Result<ENExposureConfiguration, Error>) -> Void) {
        
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.getExposureConfiguration { (result) in
                switch result {
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    case .success(let result):
                        completion(.success(ENExposureConfiguration(result)))
                        return
                }
            }
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    
    func verifyUniqueTestIdentifier(_ identifier: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        // In a real implementation, this identifer would be validated on a server
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.verifyUniqueTestIdentifier(
                identifier,
                completion: completion
            )
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
}
