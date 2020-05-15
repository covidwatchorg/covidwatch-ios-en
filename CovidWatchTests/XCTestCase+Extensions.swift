//
//  XCTestCase+Extensions.swift
//  CovidWatchTests
//
//  Created by Madhava Jay on 15/5/20.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func waitAndCheck(_ description: String = "", _ timeout: Double = 0.5, callback: () -> Bool) {
        let exp = self.expectation(description: description)
        let result = XCTWaiter.wait(for: [exp], timeout: timeout)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(callback())
        } else {
            XCTFail("Timout wating \(timeout) for \(description)")
        }
    }
    func wait(_ description: String = "", _ timeout: Double = 0.5, callback: () -> Void) {
        let exp = self.expectation(description: description)
        let result = XCTWaiter.wait(for: [exp], timeout: timeout)
        if result == XCTWaiter.Result.timedOut {
            callback()
        } else {
            XCTFail("Timout wating \(timeout) for \(description)")
        }
    }
}
