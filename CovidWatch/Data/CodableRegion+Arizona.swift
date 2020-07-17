//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import Foundation

extension CodableRegion.NextStep {

    static let infoAppIsActive: Self = .init(
        type: .info,
        description: "The app is active. You can now receive exposure notifications from others you were near who later report themselves as positive for COVID-19.",
        url: nil
    )

    static let infoKeepAppInstalled: Self = .init(
        type: .info,
        description: "Keep the app installed until the pandemic is over so that you can continue to help reduce the spread in your communities.",
        url: nil
    )

    static let shareTheApp: Self = .init(
        type: .share,
        description: "Share the app to improve your exposure notification accuracy. It works best when everyone uses it.",
        url: "https://covidwatch.org"
    )

    static let nextStepsVerificationCodeDefault: Self = .init(
        type: .phone,
        description: "For others in this region, please call Arizona Department of Health Services at (844) 542-8201 for assistance.",
        url: "tel:1-844-542-8201"
    )

}

extension CodableRegion {

    static let all: [CodableRegion] = [
        `default`,
        universityOfArizona,
        arizonaStateUniversity,
        northernArizonaUniversity
    ]

    static let `default`: Self = .init(
        id: .arizonaState,
        name: "Arizona State",
        riskLowThreshold: 0.14,
        riskHighThreshold: 3.00,
        nextStepsNoSignificantExposure: [
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .init(
                type: .phone,
                description: "Please call Arizona Department of Health Services at (844) 542-8201 for assistance.",
                url: "tel:1-844-542-8201"
            )
        ]
    )

    static let universityOfArizona: Self = .init(
        id: .universityOfArizona,
        name: "University of Arizona",
        riskLowThreshold: 0.14,
        riskHighThreshold: 3.00,
        nextStepsNoSignificantExposure: [
            .init(
                type: .website,
                description: "Monitor yourself for COVID-19 symtoms.",
                url: "https://covid19.arizona.edu/prevention-health/covid-19-symptoms?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_covid19_symptoms_no_exposure"
            ),
            .init(
                type: .phone,
                description: "If you have COVID-19 symptoms, call Campus Health at (520) 621-9202.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Learn how to protect yourself and others.",
                url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_protect_yourself"
            ),
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .init(
                type: .stayAtHomeDate,
                description: "Stay at home until: ",
                url: nil
            ),
            .init(
                type: .getTestedDate,
                description: "Call Campus Health at (520) 621-9202 and schedule a COVID-19 test for: ",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms and get tested ASAP if symptoms appear.",
                url: "https://covid19.arizona.edu/prevention-health/covid-19-symptoms?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_covid19_significant_exposure"
            ),
            .init(
                type: .website,
                description: "Register with University of Arizona's Contact Tracing team.",
                url: "https://covid19.arizona.edu/app-redcap?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_contact_tracing"
            ),
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .init(
                type: .phone,
                description: "Follow up with Campus Health at (520) 621-9202 and your healthcare provider for more instructions.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Register with University of Arizona's Contact Tracing team.",
                url: "https://health.arizona.edu/SAFER?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_case_management"
            ),
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .init(
                type: .phone,
                description: "If you are a student or staff at UArizona, please call Campus Health Services at 520-621-9202 to obtain one. If you were tested in a different region, have a copy of your results ready.",
                url: "tel:1-520-621-9202"
            ),
            .nextStepsVerificationCodeDefault
        ]
    )

    static let arizonaStateUniversity: Self = .init(
        id: .arizonaStateUniversity,
        name: "Arizona State University",
        riskLowThreshold: 0.14,
        riskHighThreshold: 3.00,
        nextStepsNoSignificantExposure: [
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .nextStepsVerificationCodeDefault
        ]
    )

    static let northernArizonaUniversity: Self = .init(
        id: .northernArizonaUniversity,
        name: "Northern Arizona University",
        riskLowThreshold: 0.14,
        riskHighThreshold: 3.00,
                nextStepsNoSignificantExposure: [
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .nextStepsVerificationCodeDefault
        ]
    )

}
