//
//  Created by Zsombor Szabo on 28/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import os.log

extension URLSessionDataTask: ServerTask {}

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
        
        let apiUrlString = "https://firestore.googleapis.com/v1/projects/covidwatch-354ce/databases/(default)/documents/positive_diagnoses"
        
        let fetchReportsUrl = URL(string: apiUrlString)!
        
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
                        response.description,
                        startDate.description
                    )
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dataDecodingStrategy = .base64
                    do {
                        os_log(
                            "JSON decoding positive diagnoses...",
                            log: .app
                        )
                        let positiveDiagnoses = try decoder.decode([PositiveDiagnosis].self, from: data)
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
            positiveDiagnosis.publicHealthAuthorityPermissionNumber
        )
        
        let apiUrlString = "https://us-central1-covidwatch-354ce.cloudfunctions.net"
        let submitUrl = URL(string: "\(apiUrlString)/submitDiagnosis")!
        
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
        
        let task = URLSession.shared.dataTask(with: request) { (result) in
            switch result {
                case .failure(let error):
                    os_log(
                        "Uploading positive diagnosis with permission number=%@ failed=%@",
                        log: .app,
                        type: .error,
                        positiveDiagnosis.publicHealthAuthorityPermissionNumber,
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
                        positiveDiagnosis.publicHealthAuthorityPermissionNumber,
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
