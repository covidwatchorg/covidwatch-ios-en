//
//  Created by Zsombor Szabo on 26/04/2020.
//

import XCTest
@testable import Covid_Watch

class CovidWatchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    public struct Challenge: Codable, Equatable {
        let workFactor: Int
        let nonce: String
    }

    public func getChallenge(
        _ completion: @escaping (Result<Challenge, Error>) -> Void
    ) {
        let apiUrlString = "http://localhost:8080"

        let fetchUrl = URL(string: "\(apiUrlString)/challenge") ??
            URL(fileURLWithPath: "")

        var request = URLRequest(url: fetchUrl)
        request.addValue("https", forHTTPHeaderField: "X-Forwarded-Proto") // for dev only not needed on the live url

        URLSession.shared.dataTask(with: request) { (result) in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success(let (response, data)):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        decoder.dataDecodingStrategy = .base64
                        let challenge = try decoder.decode(Challenge.self, from: data)
                        completion(.success(challenge))
                    } catch {
                        completion(.failure(error))
                    }
                    return
            }
        }.resume()
    }

    struct ChallengePayload: Codable {
        struct Solution: Codable {
            let nonce: String
        }
        struct Challenge: Codable {
            let nonce: String
            let workFactor: Int
        }
        let solution: Solution
        let challenge: Challenge
    }

    struct Report: Codable {
        let data: Data
    }

    struct ReportUpload: Codable {
        let report: Report
        let challenge: ChallengePayload
    }

    struct UploadToken: Codable {
        let uploadToken: String
        let uploadKey: String
    }

    public func uploadReport(
        _ report: ReportUpload,
        completion: @escaping (Result<UploadToken?, Error>) -> Void
    ) {

        let apiUrlString = "http://localhost:8080"
        let submitUrl = URL(string: "\(apiUrlString)/report") ??
            URL(fileURLWithPath: "")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dataEncodingStrategy = .base64

        var uploadData: Data! = try? encoder.encode(report)
        if uploadData == nil {
            uploadData = Data()
        }

        var request = URLRequest(url: submitUrl)
        request.addValue("https", forHTTPHeaderField: "X-Forwarded-Proto") // for dev only not needed on the live url
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let _ = URLSession.shared.uploadTask(with: request, from: uploadData) { result in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success(let (response, data)):
                    print(response, data)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dataDecodingStrategy = .base64
                    if let uploadToken = try? decoder.decode(UploadToken.self, from: data) {
                        completion(.success(uploadToken))
                        return
                    }
            }
        }.resume()
    }

    func testAPI() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var testChallenge: Challenge?
        getChallenge { result in
            switch result {
            case .success(let challenge):
                print("got a challenge: \(challenge)")
                testChallenge = challenge
            case .failure(let error):
                print("got an error: \(error)")
            }
        }

        var token: UploadToken? = nil

        wait {
            XCTAssertNotNil(testChallenge)
            XCTAssertEqual(testChallenge?.nonce.count, 32)
            XCTAssertEqual(testChallenge?.workFactor, 1024)
            print("got nonce", testChallenge?.nonce)
            if let nonce = testChallenge?.nonce,
                let work = testChallenge?.workFactor {
                let pow = ProofOfWork(challengeNonceHex: nonce, workFactor: work)
                let solver = pow.solve()
                switch solver {
                case .success(let solution):
                    print("found solution \(solution.solutionNonceHex)")
                    let report = Report(data: Data())
                    let challengeSolution = ChallengePayload.Solution(nonce: solution.solutionNonceHex)
                    let challenge = ChallengePayload.Challenge(nonce: nonce, workFactor: work)
                    let challengePayload = ChallengePayload(solution: challengeSolution, challenge: challenge)
                    let reportUpload = ReportUpload(report: report, challenge: challengePayload)
                    uploadReport(reportUpload) { result in
                        switch result {
                        case .success(let uploadToken):
                            print("Got an upload token", uploadToken)
                            token = uploadToken
                        case .failure(let error):
                            print("Upload report failed", error)
                            XCTFail("Failed uploading solution \(reportUpload) with error \(error)")
                        }
                    }
                case .failure(let error):
                    XCTFail("Failed to solve pow \(testChallenge) with error \(error)")
                }
            }
        }

        wait("Check for token", 2.0) {
            XCTAssertNotNil(token)
        }
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
