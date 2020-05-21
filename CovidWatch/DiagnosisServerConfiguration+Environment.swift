//
//  Created by Zsombor Szabo on 21/05/2020.
//
//

import Foundation

extension DiagnosisServerConfiguration {
    
    public static var current: DiagnosisServerConfiguration {
        
        let appScheme = getAppScheme()
        switch appScheme {
            case .development:
                return DiagnosisServerConfiguration(
                    apiUrlString: getAPIUrl(appScheme),
                    apiExposureURLString: getAPIUrl(appScheme) + "/exposure",
                    regions: ["US"]
            )
            case .production:
                return DiagnosisServerConfiguration(
                    apiUrlString: getAPIUrl(appScheme),
                    apiExposureURLString: "https://exposure-2sav64smma-uc.a.run.app/",
                    regions: ["US"]
            )
        }
    }
}
