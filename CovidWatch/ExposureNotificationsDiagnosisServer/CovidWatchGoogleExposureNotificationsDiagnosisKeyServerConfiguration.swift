//
//  Created by Zsombor Szabo on 02/07/2020.
//  
//

import Foundation

extension GoogleExposureNotificationsDiagnosisKeyServer.Configuration {

    static let shared: Self = .init(
        exposureBaseURLString: Bundle.main.infoDictionary?[.keyServerExposureBaseURL] as? String ?? "",
        appConfiguration: .init(regions: Bundle.main.infoDictionary?[.keyServerAppConfigurationRegions] as? [String] ?? []),
        exportConfiguration: .init(
            cloudStorageBucketName: Bundle.main.infoDictionary?[.keyServerExportConfigurationCloudStorageBucketName] as? String ?? "",
            filenameRoot: Bundle.main.infoDictionary?[.keyServerExportConfigurationFilenameRoot] as? String ?? ""
        )
    )

}
