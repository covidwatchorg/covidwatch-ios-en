//
//  Created by Zsombor Szabo on 28/04/2020.
//

import Foundation
import os.log

extension URLSession {
    
    public enum HTTPError: Error, LocalizedError {
        case transportError(Error)
        case serverSideError(Int)
        
        public var errorDescription: String? {
            switch self {
                case .transportError(let error):
                    return error.localizedDescription
                case .serverSideError(let serverSideErrorCode):
                    return String.init(
                        format: NSLocalizedString("HTTP %d", comment: ""),
                        serverSideErrorCode
                )
            }
        }
    }
    
    public typealias HTTPResult = Result<(URLResponse, Data), Error>
    
    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (HTTPResult) -> Void
    ) -> URLSessionDataTask {
        return self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(HTTPError.transportError(error)))
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                os_log(
                    "Data task with request=%@ failed with response=%@ data=%@",
                    type: .error,
                    request.description,
                    response.description,
                    String(data: data ?? Data(), encoding: .utf8) ?? ""
                )
                completionHandler(.failure(HTTPError.serverSideError(status)))
                return
            }
            completionHandler(.success((response, data!)))
        }
    }
    
    public func uploadTask(
        with request: URLRequest,
        from bodyData: Data,
        completionHandler: @escaping (HTTPResult) -> Void
    ) -> URLSessionDataTask {
        return self.uploadTask(
            with: request,
            from: bodyData
        ) { data, response, error in
            if let error = error {
                completionHandler(.failure(HTTPError.transportError(error)))
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(response.statusCode), let data = data else {
                os_log(
                    "Upload task with request=%@ from bodyData=%@ failed with response=%@",
                    type: .error,
                    request.description,
                    bodyData.description,
                    response.description
                )
                completionHandler(.failure(HTTPError.serverSideError(status)))
                return
            }
            completionHandler(.success((response, data)))
        }
    }
}
