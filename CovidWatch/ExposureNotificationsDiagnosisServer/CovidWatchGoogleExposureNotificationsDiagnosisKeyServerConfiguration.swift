//
//  Created by Zsombor Szabo on 02/07/2020.
//  
//

import Foundation

extension GoogleExposureNotificationsDiagnosisKeyServer.Configuration {

    static let shared: Self = .init(
        exposureBaseURLString: Bundle.main.infoDictionary?[
            CovidWatchInfoDictionaryKeys.keyServerExposureBaseURL
            ] as? String ?? "",
        appConfiguration: .init(regions: Bundle.main.infoDictionary?[
            CovidWatchInfoDictionaryKeys.keyServerAppConfigurationRegions
            ] as? [String] ?? []),
        exportConfiguration: .init(
            cloudStorageBucketName: Bundle.main.infoDictionary?[
                CovidWatchInfoDictionaryKeys.keyServerExportConfigurationCloudStorageBucketName
                ] as? String ?? "",
            filenameRoot: Bundle.main.infoDictionary?[
                CovidWatchInfoDictionaryKeys.keyServerExportConfigurationFilenameRoot
                ] as? String ?? ""
        )
    )

}
