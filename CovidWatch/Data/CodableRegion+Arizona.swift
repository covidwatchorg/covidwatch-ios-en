//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import Foundation

extension CodableRegion {

    static let all: [CodableRegion] = [
        `default`,
        universityOfArizona
    ]

    static let `default`: Self = .init(
        name: "Arizona State",
        logoTypeImageName: "Public Health Authority Logotype - Arizona State",
        logoImageName: "Public Health Authority Logo - Arizona State",
        website: "https://www.azdhs.gov",
        nextStepsRiskLow: [
            .init(type: .phone, url: "tel:1-520-621-9202", description: "If you have COVID-19 symptoms, call Campus Health at (520) 621-9202"),
            .init(type: .phone, url: "tel:1-520-621-9202", description: "If you have COVID-19 symptoms, call Campus Health at (520) 621-9202"),
        ]
    )

    static let universityOfArizona: Self = .init(
        name: "University of Arizona",
        logoTypeImageName: "Public Health Authority Logotype - University of Arizona",
        logoImageName: "Public Health Authority Logo - University of Arizona",
        website: "https://www.arizona.edu",
        nextStepsRiskLow: [
            .init(type: .website, url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_ios_app&utm_medium=referral&utm_campaign=covid_watch_protect_yourself", description: "Monitor yourself for COVID-19 symtoms"),
            .init(type: .phone, url: "tel:1-520-621-9202", description: "If you have COVID-19 symptoms, call Campus Health at (520) 621-9202"),
            .init(type: .website, url: "http://covid19.arizona.edu/prevention-health/protect-yourself-others?utm_source=covid_watch_ios_app&utm_medium=referral&utm_campaign=covid_watch_protect_yourself", description: "Protect yourself and others"),
        ]
    )

}
