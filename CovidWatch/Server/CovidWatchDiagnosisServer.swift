//
//  Created by Zsombor Szabo on 28/04/2020.
//

import Foundation
import os.log

extension URLSessionDataTask: ServerTask {}

public struct PositiveDiagnosisResponse: Codable {
    let status: String
    let message: String
    let data: [PositiveDiagnosis]
}

class CovidWatchDiagnosisServer: DiagnosisServer {
    
    func fetch(
        since startDate: Date,
        completion: @escaping (Result<[PositiveDiagnosis], Error>) -> Void
    ) -> ServerTask {
        
        os_log(
            "Fetching positive diagnoses since=%@ ...",
            log: .app,
            startDate.description
        )

        let apiUrlString = getAPIUrl(getAppScheme())
        let fetchReportsUrl = URL(string: "\(apiUrlString)/fetchDiagnosis") ?? URL(fileURLWithPath: "")
        
        let request = URLRequest(url: fetchReportsUrl)
        
        let task = URLSession.shared.dataTask(with: request) { (result) in
            switch result {                
                case .failure(let error):
                    os_log(
                        "Fetching positive diagnoses since=%@ failed=%@",
                        log: .app,
                        type: .error,
                        startDate.description,
                        error as CVarArg
                    )
                    completion(.failure(error))
                    return
                
                case .success(let (response, data)):
                    os_log(
                        "Fetched positive diagnoses since=%@ response=%@",
                        log: .app,
                        startDate.description,
                        response.description
                    )
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dataDecodingStrategy = .base64

                    enum DateError: String, Error {
                        case invalidDate
                    }

                    let formatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .iso8601)
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)

                    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)

                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                        if let date = formatter.date(from: dateStr) {
                            return date
                        }
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
                        if let date = formatter.date(from: dateStr) {
                            return date
                        }
                        throw DateError.invalidDate
                    })

                    do {
                        os_log(
                            "JSON decoding positive diagnoses...",
                            log: .app
                        )
                        let positiveDiagnoseResponse = try decoder.decode(PositiveDiagnosisResponse.self, from: data)
                        let positiveDiagnoses = positiveDiagnoseResponse.data

                        os_log(
                            "JSON decoded positive diagnoses",
                            log: .app
                        )
                        completion(.success(positiveDiagnoses))
                    }
                    catch {
                        completion(.failure(error))
                    }
                    return
            }
        }
        task.resume()
        return task
    }
    
    func upload(
        positiveDiagnosis: PositiveDiagnosis,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> ServerTask {
        
        os_log(
            "Uploading positive diagnosis with permission number=%@ ...",
            log: .app,
            positiveDiagnosis.publicHealthAuthorityPermissionNumber ?? ""
        )

        let apiUrlString = getAPIUrl(getAppScheme())
        let submitUrl = URL(string: "\(apiUrlString)/submitDiagnosis") ?? URL(fileURLWithPath: "")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dataEncodingStrategy = .base64
        
        var uploadData: Data! = try? encoder.encode(positiveDiagnosis)
        if uploadData == nil {
            uploadData = Data()
        }
        
        var request = URLRequest(url: submitUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.uploadTask(with: request, from: uploadData) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Uploading positive diagnosis with permission number=%@ failed=%@",
                        log: .app,
                        type: .error,
                        positiveDiagnosis.publicHealthAuthorityPermissionNumber ?? "",
                        error as CVarArg
                    )
                    completion(.failure(error))
                    return
                
                case .success(let (response, data)):
                    var serverResponse = ""
                    if let mimeType = response.mimeType,
                        mimeType == "application/json",
                        let dataString = String(data: data, encoding: .utf8) {
                        
                        serverResponse = dataString
                    }
                    os_log(
                        "Uploaded positive diagnosis with permission number=%@ response=%@",
                        log: .app,
                        positiveDiagnosis.publicHealthAuthorityPermissionNumber ?? "",
                        serverResponse
                    )
                    completion(.success(()))
                    return
            }
        }
        task.resume()
        return task
    }
    
}


typealias HTTPResult = Result<(URLResponse, Data), Error>

extension URLSession {
    static func uploadTask(with: URLRequest, from: Data, result: @escaping (HTTPResult) -> Void) -> URLSessionDataTask {
        return URLSession.shared.uploadTask(with: with, from: from) { data, response, error in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode), let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
