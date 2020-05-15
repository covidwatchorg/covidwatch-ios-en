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
        )
    ]

    func testPoW() throws {
        for task in powData {
            let pow = ProofOfWork(challengeNonceHex: task.challengeNonceHex, workFactor: task.workFactor)
            let solver = pow.solve()
            switch solver {
            case .success(let solution):
                XCTAssertEqual(task.challengeNonceHex, solution.challengeNonceHex)
                XCTAssertTrue(solution.isValid())
            case .failure(let error):
                XCTFail("Failed to solve pow \(task) with error \(error)")
            }
        }
    }
}
