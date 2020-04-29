//
//  Created by Zsombor Szabo on 28/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension URLSession {
    
    public enum HTTPError: Error, LocalizedError {
        case transportError(Error)
        case serverSideError(Int)
        
        public var errorDescription: String? {
            switch self {
                case .transportError(let error):
                    return error.localizedDescription
                case .serverSideError(let serverSideErrorCode):
                    return String.init(format: NSLocalizedString("HTTP %d", comment: ""), serverSideErrorCode)
            }
        }
    }
    
    public typealias DataTaskResult = Result<(HTTPURLResponse, Data), Error>
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (DataTaskResult) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(Result.failure(HTTPError.transportError(error)))
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                //print(String(data: data ?? Data(), encoding: .utf8) ?? <#default value#>)
                completionHandler(Result.failure(HTTPError.serverSideError(status)))
                return
            }
            completionHandler(Result.success((response, data!)))
        }
    }
}
