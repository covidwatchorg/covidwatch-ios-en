//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import Foundation

extension CodableRegion.NextStep {

    static let nextStepsVerificationCodeDefault: Self = .init(
        type: .website,
        description: "For others in Arizona, the statewide app is under development. Visit the Covid Watch website to let us know your thoughts on the app.",
        url: "https://www.covidwatch.org/partners/adhs-feedback"
    )

}

extension CodableRegion {

    static let all: [CodableRegion] = [
        `default`,
        universityOfArizona,
        northernArizonaUniversity,
        bermuda
    ]

    static let `default`: Self = .init(
        id: .arizonaState,
        name: "State of Arizona",
        isDisabled: true,
        nextStepsNoSignificantExposure: [
            .whyDidIReceiveAnExposureNotification,
            .init(
                type: .website,
                description: "Visit the Covid Watch website to share your feedback on the app.",
                url: "https://www.covidwatch.org/partners/adhs-feedback"
            ),
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .init(
                type: .website,
                description: "Learn how to protect myself and others.",
                url: "https://azdhs.gov/preparedness/epidemiology-disease-control/infectious-disease-epidemiology/index.php#novel-coronavirus-what-everyone-needs"
            ),
            .init(
                type: .website,
                description: "Find a test site if symptoms appear.",
                url: "https://azdhs.gov/preparedness/epidemiology-disease-control/infectious-disease-epidemiology/index.php#novel-coronavirus-testing"
            ),
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .init(
                type: .website,
                description: "Learn how to protect myself and others.",
                url: "https://azdhs.gov/preparedness/epidemiology-disease-control/infectious-disease-epidemiology/index.php#novel-coronavirus-what-everyone-needs"
            ),
            .init(
                type: .website,
                description: "Find a test site.",
                url: "https://azdhs.gov/preparedness/epidemiology-disease-control/infectious-disease-epidemiology/index.php#novel-coronavirus-testing"
            ),
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .init(
                type: .selectRegion,
                description: "Statewide app support is currently under development. You will continue to get exposure notifications, but can only share an anonymous COVID-19 diagnosis if you are part of a region with full app support.",
                url: nil
            )
        ]
    )

    static let universityOfArizona: Self = .init(
        id: .universityOfArizona,
        name: "University of Arizona",
        nextStepsNoSignificantExposure: [
            .whyDidIReceiveAnExposureNotification,
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms.",
                url: "https://covid19.arizona.edu/prevention-health/covid-19-symptoms-prevention?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_covid19_symptoms_no_exposure"
            ),
            .init(
                type: .phone,
                description: "If you have COVID-19 symptoms, call Campus Health at (520) 621-9202.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Learn how to protect yourself and others.",
                url: "https://covid19.arizona.edu/face-coverings?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_protect_yourself"
            ),
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .init(
                type: .website,
                description: "Stay at home until DAYS_FROM_EXPOSURE{LATEST,14,FALSE}.",
                url:"http://covid19.arizona.edu/self-quarantine?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_self_quarantine"
            ),
            .init(
                type: .phone,
                description: "Call Campus Health at (520) 621-9202 and schedule a COVID-19 test for DAYS_FROM_EXPOSURE{EARLIEST,7,TRUE}.",
                url: "tel:1-520-621-9202"
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms and get tested ASAP if symptoms appear.",
                url: "https://covid19.arizona.edu/prevention-health/covid-19-symptoms-prevention? utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_covid19_symptoms"
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
                description: "If you are a student, faculty, or staff member at University of Arizona, please call Campus Health Services at 520-621-9202 to obtain one. If you were tested elsewhere, please have your results ready.",
                url: "tel:1-520-621-9202"
            ),
            .nextStepsVerificationCodeDefault
        ]
    )

    static let arizonaStateUniversity: Self = .init(
        id: .arizonaStateUniversity,
        name: "Arizona State University",
        nextStepsNoSignificantExposure: [
            .whyDidIReceiveAnExposureNotification,
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
        nextStepsNoSignificantExposure: [
            .whyDidIReceiveAnExposureNotification,
            .init(
                type: .website,
                description: "Learn how to protect myself and others.",
                url: "https://in.nau.edu/campus-health-services/covid-19?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_protect_yourself"
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms.",
                url: "https://www.cdc.gov/coronavirus/2019-ncov/symptoms-testing/symptoms.html?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_covid19_symptoms_no_exposure"
            ),
            .init(
                type: .phone,
                description: "If you have COVID-19 symptoms, call Campus Health at (928) 523-2131.",
                url: "tel:1-928-523-2131"
            ),
            .shareTheApp
        ],
        nextStepsSignificantExposure: [
            .init(
                type: .website,
                description: "Please stay at home and follow the self-isolation guidelines.",
                url:"https://in.nau.edu/wp-content/uploads/sites/202/COVID-CHS-selfquarantine-7-16-20.pdf?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_self_quarantine"
            ),
            .init(
                type: .website,
                description: "Monitor COVID-19 symptoms and get tested ASAP if symptoms appear.",
                url:"https://in.nau.edu/campus-health-services/covid-testing? utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_covid19_symptoms"
            ),
            .init(
                type: .phone,
                description: "Call Campus Health at (928) 523-2131 or your health care provider for guidance.",
                url: "tel:1-928-523-2131"
            ),
            .shareTheApp
        ],
        nextStepsVerifiedPositive: [
            .init(
                type: .website,
                description: "Please stay at home and follow the self-isolation guidelines.",
                url:"https://in.nau.edu/wp-content/uploads/sites/202/COVID-CHS-selfisolation-7-16-201.pdf?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_self_quarantine"
            ),
            .init(
                type: .phone,
                description: "Follow up with Campus Health at (928) 523-2131 or your healthcare provider for more instructions.",
                url: "tel:1-928-523-2131"
            ),
            .init(
                type: .website,
                description: "Register with NAU's Exposure Tracing team.",
                url: "https://in.nau.edu/campus-health-services/exposure-tracing?utm_source=covid_watch_app&utm_medium=referral&utm_campaign=covid_watch_case_management"
            ),
            .shareTheApp
        ],
        nextStepsVerificationCode: [
            .init(
                type: .phone,
                description: "If you are a student, faculty, or staff at NAU, please call Campus Health Services at (928) 523-2131 to obtain one. If you were tested elsewhere, have a copy of your results ready.",
                url: "tel:1-928-523-2131"
            ),
            .nextStepsVerificationCodeDefault
        ]
    )

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
