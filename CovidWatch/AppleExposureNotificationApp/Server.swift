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
    
    enum CodingKeys: String, CodingKey {
        case keyData = "key"
        case rollingPeriod
        case rollingStartNumber
        case transmissionRiskLevel = "transmissionRisk"
    }
}

public struct CodableExposureConfiguration: Codable {
    let minimumRiskScore: ENRiskScore
    #if DEBUG_CALIBRATION
    let attenuationDurationThresholdList: [[Int]]
    #else
    let attenuationDurationThresholds: [Int]
    #endif
    let attenuationLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let durationLevelValues: [ENRiskLevelValue]
    let transmissionRiskLevelValues: [ENRiskLevelValue]
}

@available(iOS 13.5, *)
public class Server {
    
    public init() {}
    
    public static let shared = Server()
    
    public var diagnosisServer: DiagnosisServer?
    
    func postDiagnosisKeys(_ diagnosisKeys: [ENTemporaryExposureKey], completion: @escaping (Error?) -> Void) {
        
        // Convert keys to something that can be encoded to JSON and upload them.
        let codableDiagnosisKeys = diagnosisKeys.compactMap { diagnosisKey -> CodableDiagnosisKey? in
            return CodableDiagnosisKey(keyData: diagnosisKey.keyData,
                                       rollingPeriod: diagnosisKey.rollingPeriod,
                                       rollingStartNumber: diagnosisKey.rollingStartNumber,
                                       transmissionRiskLevel: diagnosisKey.transmissionRiskLevel)            
        }
        
        // Your server needs to handle de-duplicating keys.
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.postDiagnosisKeys(
                codableDiagnosisKeys,
                completion: completion
            )
        }
        else {
            completion(CocoaError(.fileNoSuchFile))
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
    func downloadDiagnosisKeyFile(at remoteURL: URL, completion: @escaping (Result<[URL], Error>) -> Void) {
        
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
    
    func deleteDiagnosisKeyFile(at localURLs: [URL]) throws {
        for localURL in localURLs {
            try FileManager.default.removeItem(at: localURL)
        }
    }

    func getExposureConfiguration(completion: @escaping (Result<ENExposureConfiguration, Error>) -> Void) {
        
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.getExposureConfiguration(completion: completion)
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    
    #if DEBUG_CALIBRATION
    func getExposureConfigurationList(completion: @escaping (Result<[ENExposureConfiguration], Error>) -> Void) {
        
        if let diagnosisServer = self.diagnosisServer {
            
            diagnosisServer.getExposureConfigurationList(completion: completion)
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    #endif
    
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
