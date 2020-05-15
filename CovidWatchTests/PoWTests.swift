//
//  PoWTests.swift
//  CovidWatchTests
//
//  Created by Madhava Jay on 15/5/20.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import XCTest
@testable import Covid_Watch

class PoWTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    var powData: [PoWSolution] = [
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "15b59b443d8c662473e1534189e46f17"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "9e0a70133103679d45095d214d068e05"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "9fcb507b5dd857bb52f9026d647b3312"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "02f9a1d73a3d5dc00a42200002f52172"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "1b1161ff9ec79eb9b478ba937beb36d5"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "e8d746216d05a1b3027183de1a721b81"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "e1a7bba7f5dc93815184cfa07c6fdaee"
        ),
        PoWSolution(
            challengeNonceHex: "0e0e6fd368aac433f4b59ce218233385",
            workFactor: 1024,
            solutionNonceHex: "a7f9f4f8053f6744d92eedca01c6577a"
        )
    ]

    func testPoW() throws {
        self.measure {
            for task in powData {
                let pow = ProofOfWork(challengeNonceHex: task.challengeNonceHex, workFactor: task.workFactor)
                let solver = pow.solve()
                switch solver {
                case .success(let solution):
                    XCTAssertEqual(solution, task)
                case .failure(let error):
                    XCTFail("Failed to solve pow \(task) with error \(error)")
                }
            }
        }
    }
}
