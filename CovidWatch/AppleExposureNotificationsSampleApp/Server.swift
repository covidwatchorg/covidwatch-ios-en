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
    
    func postDiagnosisKeys(_ diagnosisKeys: [ENTemporaryExposureKey], completion: @escaping (Error?) -> Void) {
                        
        if let diagnosisServer = self.keyServer {
            
            diagnosisServer.postDiagnosisKeys(
                diagnosisKeys,
                completion: completion
            )
        }
        else {
            completion(CocoaError(.fileNoSuchFile))
        }
    }
    
    func getDiagnosisKeyFileURLs(startingAt index: Int, completion: @escaping (Result<[URL], Error>) -> Void) {
        
        if let diagnosisServer = self.keyServer {
            
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
        
        if let diagnosisServer = self.keyServer {
            
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
        
        if let diagnosisServer = self.keyServer {
            
            diagnosisServer.getExposureConfiguration(completion: completion)
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    
    #if DEBUG_CALIBRATION
    func getExposureConfigurationList(completion: @escaping (Result<[ENExposureConfiguration], Error>) -> Void) {
        
        if let keyServer = self.keyServer {
            
            keyServer.getExposureConfigurationList(completion: completion)
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
    #endif
    
    func verifyUniqueTestIdentifier(_ identifier: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // In a real implementation, this identifer would be validated on a server
        if let verificationServer = self.verificationServer {
            
            verificationServer.verifyUniqueTestIdentifier(
                identifier,
                completion: completion
            )
        }
        else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
        }
    }
}
