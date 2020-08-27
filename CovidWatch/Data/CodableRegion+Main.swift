//
//  Created by Zsombor Szabo on 25.08.2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension CodableRegion.NextStep {

    static let nextStepsVerificationCodeDefault: Self = .init(
        type: .website,
        description: "For others, please visit the Covid Watch website to let us know your thoughts on the app.",
        url: "https://www.covidwatch.org/partners/bermuda-feedback"
    )

}

extension CodableRegion {

    static let all: [CodableRegion] = [
        `default`,
    ]

    static let `default` = bermuda

    static let bermuda: Self = .init(
        id: .bermuda,
        name: "Bermuda",
        nextStepsNoSignificantExposure: [
            .init(
                type: .website,
                description: "Learn how to protect myself and others.",
                url: "https://www.gov.bm/coronavirus-guidance"
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms.",
                url: "https://www.gov.bm/coronavirus-guidance"
            ),
            .init(
                type: .phone,
                description: "If you have COVID-19 symptoms, call (441) 278-4900.",
                url: "tel:1-441-278-4900"
            ),
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .init(
                type: .website,
                description: "Stay at home until DAYS_FROM_EXPOSURE{LATEST,14,FALSE}.",
                url:"https://www.gov.bm/coronavirus-guidance"
            ),
            .init(
                type: .phone,
                description: "Call (441) 278-4900 and schedule a COVID-19 test for DAYS_FROM_EXPOSURE{EARLIEST,7,TRUE}.",
                url: "tel:1-441-278-4900"
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms and get tested ASAP if symptoms appear.",
                url:"https://www.gov.bm/coronavirus-get-tested"
            ),
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .init(
                type: .website,
                description: "Follow up with (441) 278-4900 and your healthcare provider for more instructions.",
                url: "tel:1-441-278-4900"
            ),
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .init(
                type: .phone,
                description: "If you got tested in Bermuda, call (441) 278-4900 to obtain a verification code. If you were tested elsewhere, have a copy of your results ready.",
                url: "tel:1-441-278-4900"
            ),
        ]
    )
}
