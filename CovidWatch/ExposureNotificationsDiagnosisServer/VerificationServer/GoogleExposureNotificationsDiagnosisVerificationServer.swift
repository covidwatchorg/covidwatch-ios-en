//
//  Created by Zsombor Szabo on 01/07/2020.
//  
//

import Foundation
import os.log

@available(iOS 13.5, *)
public class GoogleExposureNotificationsDiagnosisVerificationServer: ExposureNotificationsDiagnosisVerificationProviding {
    
    public struct Configuration {
        let apiServerBaseURLString: String
        let apiKey: String        
    }
    
    public var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func verifyUniqueTestIdentifier(
        _ identifier: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        os_log(
            "Verifying unique test identifier=%@ ...",
            log: .en,
            identifier
        )
        
        guard let url = URL(string: "\(self.configuration.apiServerBaseURLString)/api/verify") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let codableVerifyCodeRequest = CodableVerifyCodeRequest(code: identifier)
        
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
        
        URLSession.shared.uploadTask(
            with: request,
            from: uploadData
        ) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Verifying unique test identifier=%@ failed=%@ ...",
                        log: .en,
                        type: .error,
                        identifier,
                        error as CVarArg
                    )
                    completion(.failure(error))
                    return
                
                case .success(let (response, _)):
                    os_log(
                        "Verified unique test identifier=%@ response=%@",
                        log: .en,
                        identifier,
                        response.description
                    )
                    //                    completion(.success(true))
                    return
            }
        }.resume()
    }
    
}
