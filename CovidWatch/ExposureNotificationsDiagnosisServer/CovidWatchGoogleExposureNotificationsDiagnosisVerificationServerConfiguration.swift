//
//  Created by Zsombor Szabo on 02/07/2020.
//  
//

import Foundation

extension GoogleExposureNotificationsDiagnosisVerificationServer.Configuration {
    
    static let shared: Self = .init(
        apiServerBaseURLString: Bundle.main.infoDictionary?[CovidWatchInfoDictionaryKeys.verificationServerApiServerBaseURL] as! String,
        // TODO: Get API key through on-demand resources, to increase security.
        apiKey: Bundle.main.infoDictionary?[CovidWatchInfoDictionaryKeys.verificationServerApiKey] as! String
    )
    
}
