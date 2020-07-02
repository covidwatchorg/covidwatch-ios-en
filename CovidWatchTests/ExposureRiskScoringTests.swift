//
//  Created by Zsombor Szabo on 08/06/2020.
//  
//

import XCTest
@testable import CovidWatch
import ExposureNotification

class ExposureRiskScoringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAZExposureRiskScorer() {
        let scoring = AZExposureRiskScorer()
        let message = "Computed risk score does not match expected risk score"

        // Scenario: "Sufficiently risky individual, 30 minutes close contact"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 30 * 60), NSNumber(value: 0), NSNumber(value: 0)],
                transmissionRiskLevel: 4
            ),
            8, // Expected
            message
        )

        // Scenario: "Sufficiently risky individual, 30 minutes at med. attenuation"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 30 * 60), NSNumber(value: 0)],
                transmissionRiskLevel: 4
            ),
            4, // Expected
            message
        )

        // Scenario: "Sufficiently risky individual, 5 minutes close contact"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 5 * 60), NSNumber(value: 0), NSNumber(value: 0)],
                transmissionRiskLevel: 4
            ),
            0, // Expected
            message
        )

        // Scenario: "Highest risk individual, 30 minutes at med. attenuation"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 30 * 60), NSNumber(value: 0)],
                transmissionRiskLevel: 6
            ),
            8, // Expected
            message
        )

        // Scenario: "Highest risk individual, 5 minutes close contact"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 5 * 60), NSNumber(value: 0), NSNumber(value: 0)],
                transmissionRiskLevel: 6
            ),
            2, // Expected
            message
        )

        // Scenario: "Highest risk individual, 5 minutes at med attenuation"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 5 * 60), NSNumber(value: 0)],
                transmissionRiskLevel: 6
            ),
            0, // Expected
            message
        )

        // Scenario: "Highest risk individual, 30 minutes at long distance"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: 30 * 60)],
                transmissionRiskLevel: 6
            ),
            5, // Expected
            message
        )

        // Scenario: "Asymptomatic shedder at peak risk, 30 min at med. attenuation"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 30 * 60), NSNumber(value: 0)],
                transmissionRiskLevel: 3
            ),
            2, // Expected
            message
        )

        // Scenario: "Low shedder, 30 min at medium attenuation"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 30 * 60), NSNumber(value: 0)],
                transmissionRiskLevel: 2
            ),
            1, // Expected
            message
        )

        // Scenario: "Low shedder, 5 min at med. attenuation"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 5 * 60), NSNumber(value: 0)],
                transmissionRiskLevel: 2
            ),
            0, // Expected
            message
        )

        // Scenario: "Highest risk individual, 30 min in each bucket"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 30 * 60), NSNumber(value: 30 * 60), NSNumber(value: 30 * 60)],
                transmissionRiskLevel: 6
            ),
            8, // Expected
            message
        )

        // Scenario: "Highest risk individual, 30 min in each bucket"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 30 * 60), NSNumber(value: 30 * 60), NSNumber(value: 30 * 60)],
                transmissionRiskLevel: 1
            ),
            2, // Expected
            message
        )

        // Scenario: "Highest risk individual 15 minutes close contact"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 15 * 60), NSNumber(value: 0), NSNumber(value: 0)],
                transmissionRiskLevel: 6
            ),
            8, // Expected
            message
        )

        // Scenario: "Lowest risk individual 15 minutes close contact"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 15 * 60), NSNumber(value: 0), NSNumber(value: 0)],
                transmissionRiskLevel: 1
            ),
            0, // Expected
            message
        )

        // Scenario: "Highest risk individual 15 minutes long distance"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: 15 * 60)],
                transmissionRiskLevel: 6
            ),
            2, // Expected
            message
        )

        // Scenario: "Lowest risk individual 15 minutes long distance"
        XCTAssertEqual(
            scoring.computeRiskScore(
                forAttenuationDurations: [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: 15 * 60)],
                transmissionRiskLevel: 1
            ),
            0, // Expected
            message
        )
    }

}
