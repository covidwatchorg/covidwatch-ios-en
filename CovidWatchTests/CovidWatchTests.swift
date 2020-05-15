//
//  Created by Zsombor Szabo on 26/04/2020.
//

import XCTest
@testable import Covid_Watch
import CatCrypto

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

        wait {
            XCTAssertNotNil(testChallenge)
            XCTAssertEqual(testChallenge?.nonce.count, 32)
            XCTAssertEqual(testChallenge?.workFactor, 1024)
            print("got nonce", testChallenge?.nonce)
            if let nonce = testChallenge?.nonce {
                let argon = CatArgon2Crypto()
                argon.context.mode = .argon2id
                let answer = argon.hash(password: nonce)
                print("got answer", answer)
            }
        }
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
