//
//  Created by Zsombor Szabo on 05/07/2020.
//  
//

import XCTest
@testable import CovidWatch
import ExposureNotification

class ENVerificationUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalculateHMAC() {
        let secret = Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])

        let key1 = ENTemporaryExposureKey()
        key1.keyData = Data(base64Encoded: "z2Cx9hdz2SlxZ8GEgqTYpA==")!
        key1.rollingStartNumber = 1
        key1.rollingPeriod = 144
        key1.transmissionRiskLevel = 3

        let key2 = ENTemporaryExposureKey()
        key2.keyData = Data(base64Encoded: "dPCphLzfG4uzXneNimkPRQ==")!
        key2.rollingStartNumber = 144
        key2.rollingPeriod = 144
        key2.transmissionRiskLevel = 5

        let got = try? ENVerificationUtils.calculateExposureKeyHMAC(
            forTemporaryExposureKeys: [key1, key2],
            secret: secret
        ).base64EncodedString()
        let want = "2u1nHt5WWurJytFLF3xitNzM99oNrad2y4YGOL53AeY="
        XCTAssertEqual(got, want)
    }

}
