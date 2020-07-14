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

        // Current date
        let day0 = Date()
        let day2 = Calendar.current.date(byAdding: .day, value: 2, to: day0)!
        let day3 = Calendar.current.date(byAdding: .day, value: 3, to: day0)!
        let day4 = Calendar.current.date(byAdding: .day, value: 4, to: day0)!
        let day18 = Calendar.current.date(byAdding: .day, value: 18, to: day0)!

        var exposures = [Exposure(
                            attenuationDurations: [5 * 60.0, 10 * 60.0, 5 * 60.0],
                              attenuationValue: 0,
                              date: day0,
                              duration: 0,
                              totalRiskScore: 0,
                              transmissionRiskLevel: 6
                            ),
                         Exposure(
                            attenuationDurations: [10 * 60.0, 0.0, 0.0],
                           attenuationValue: 0,
                           date: day3,
                           duration: 0,
                           totalRiskScore: 0,
                           transmissionRiskLevel: 6
                         )
            ]

        XCTAssertEqual(
            scoring.computeDateRiskLevel(forExposures: exposures, forDate: day2
            ),
            4.147819, // Expected
            accuracy: 0.0001,
            message
        )
        XCTAssertEqual(
            scoring.computeDateRiskLevel(forExposures: exposures, forDate: day3
            ),
            7.221063, // Expected
            accuracy: 0.0001,
            message
        )
        XCTAssertEqual(
            scoring.computeDateRiskLevel(forExposures: exposures, forDate: day18
            ),
            2.251825, // Expected
            accuracy: 0.0001,
            message
        )

        exposures = [Exposure(
                        attenuationDurations: [0.0, 0.0, 25 * 60.0],
                          attenuationValue: 0,
                          date: day3,
                          duration: 0,
                          totalRiskScore: 0,
                          transmissionRiskLevel: 6
                        ),
                     Exposure(
                        attenuationDurations: [5 * 60.0, 20 * 60.0, 5 * 60.0],
                       attenuationValue: 0,
                       date: day3,
                       duration: 0,
                       totalRiskScore: 0,
                       transmissionRiskLevel: 6
                     ),
                     Exposure(
                        attenuationDurations: [5 * 60.0, 0.0, 0.0],
                       attenuationValue: 0,
                       date: day3,
                       duration: 0,
                       totalRiskScore: 0,
                       transmissionRiskLevel: 6
                     )
        ]

        XCTAssertEqual(
            scoring.computeDateRiskLevel(forExposures: exposures, forDate: day2
            ),
            0.0, // Expected
            accuracy: 0.0001,
            message
        )
        XCTAssertEqual(
            scoring.computeDateRiskLevel(forExposures: exposures, forDate: day4
            ),
            10.2363, // Expected
            accuracy: 0.0001,
            message
        )
        XCTAssertEqual(
            scoring.computeDateRiskLevel(forExposures: exposures, forDate: day18
            ),
            3.489957, // Expected
            accuracy: 0.0001,
            message
        )
    }

}
