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
                description: "Monitor COVID-19 symptoms.",
                url: "https://www.gov.bm/sites/default/files/COVID-19-Symptom-Self-Assessment-v2.pdf"
            ),
            .init(
                type: .phone,
                description: "If you have COVID-19 symptoms, call the Government COVID-19 Hotline at 1-(441)-444-2498.",
                url: "tel:1-441-444-2498"
            ),
            .init(
                type: .website,
                description: "Learn how to protect myself and others.",
                url: "https://www.gov.bm/coronavirus-wellbeing"
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
                description: "Call the Government COVID-19 Hotline at 1-(441)-444-2498 and schedule a COVID-19 test for DAYS_FROM_EXPOSURE{EARLIEST,7,TRUE}.",
                url: "tel:1-441-444-2498"
            ),
            .init(
                type: .website,
                description: "If you have symptoms follow the self-quaratine guidelines.",
                url:"https://www.gov.bm/sites/default/files/11436%20-%20Coronavirus%202020_Precautions%20Poster_2_0.pdf"
            ),
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .init(
                type: .website,
                description: "Follow up with the Government COVID-19 Hotline at 1-(441)-444-2498 or your healthcare provider for more instructions.",
                url: "tel:1-441-444-2498"
            ),
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .init(
                type: .phone,
                description: "For those located in Bermuda, please call the Government COVID-19 Hotline at 1-(441)-444-2498 to obtain one. If you were tested elsewhere, please have the documentation of your test result ready.",
                url: "tel:1-441-444-2498"
            ),
        ]
    )
}
