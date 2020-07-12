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
        description: "Share the app to improve your exposure notification and risk level accuracy. It works best when everyone uses it.",
        url: "https://covidwatch.org"
    )

}

extension CodableRegion {

    static let all: [CodableRegion] = [
        `default`,
        universityOfArizona
    ]

    static let `default`: Self = .init(
        id: 0,
        name: "Arizona State",
        logoTypeImageName: "Public Health Authority Logotype - Arizona State",
        logoImageName: "Public Health Authority Logo - Arizona State",
        riskLowThreshold: 0.14,
        riskHighThreshold: 3.00,
        nextStepsRiskUnknown: [
            .infoAppIsActive,
            .infoKeepAppInstalled,
            .init(
                type: .website,
                description: "Visit the Public Health Website for local resources that are available to you.",
                url: "https://www.azdhs.gov"
            ),
            .shareTheApp
        ],
        nextStepsRiskLow: [
            .shareTheApp
        ],
        nextStepsRiskMedium: [
            .shareTheApp
        ],
        nextStepsRiskHigh: [
            .shareTheApp
        ],
        nextStepsRiskVerifiedPositive: [
            .shareTheApp
        ]
    )

    static let universityOfArizona: Self = .init(
        id: 1,
        name: "University of Arizona",
        logoTypeImageName: "Public Health Authority Logotype - University of Arizona",
        logoImageName: "Public Health Authority Logo - University of Arizona",
        riskLowThreshold: 0.14,
        riskHighThreshold: 3.00,
        nextStepsRiskUnknown: [
            .infoAppIsActive,
            .infoKeepAppInstalled,
            .init(
                type: .website,
                description: "Visit the University of Arizona website for local resources that are available to you.",
                url: "https://arizona.edu"
            ),
            .shareTheApp
        ],
        nextStepsRiskLow: [
            .init(
                type: .website,
                description: "Monitor yourself for COVID-19 symtoms.",
                url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_ios_app&utm_medium=referral&utm_campaign=covid_symptoms"
            ),
            .init(
                type: .phone,
                description: "If you have COVID-19 symptoms, call Campus Health at (520) 621-9202.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Protect yourself and others.",
                url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_ios_app&utm_medium=referral&utm_campaign=covid_watch_protect_yourself"
            ),
            .shareTheApp
        ],
        nextStepsRiskMedium: [
            .init(
                type: .phone,
                description: "Call Campus Health at (520) 621-9202.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Monitor yourself for COVID-19 symtoms.",
                url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_ios_app&utm_medium=referral&utm_campaign=covid_symptoms"
                ),
            .shareTheApp
        ],
        nextStepsRiskHigh: [
            .init(
                type: .phone,
                description: "Stay at home and contact Campus Health at (520) 621-9202.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .getTestedDates,
                description: "Schedule a COVID-19 test between: ",
                url: nil
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms and get tested ASAP if symptoms appear.",
                url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_ios_app&utm_medium=referral&utm_campaign=covid_symptoms"
            ),
            .init(
                type: .website,
                description: "Register with University of Arizona's Contact Tracing team.",
                url: "https://covid19.arizona.edu/app-redcap?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_contact_tracing"
            ),
            .shareTheApp
        ],
        nextStepsRiskVerifiedPositive: [
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
        ]
    )

}
