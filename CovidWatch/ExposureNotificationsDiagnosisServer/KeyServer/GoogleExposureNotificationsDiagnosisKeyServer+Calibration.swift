//
//  Created by Zsombor Szabo on 24/06/2020.
//  
//

import Foundation
import os.log
import ExposureNotification
import DeviceCheck
import ZIPFoundation

#if DEBUG_CALIBRATION
extension GoogleExposureNotificationsDiagnosisKeyServer {
    
    public func getExposureConfigurationList(completion: (Result<[ENExposureConfiguration], Error>) -> Void) {
        os_log(
            "Getting exposure configuration from server ...",
            log: .en
        )

        let dataFromServer = LocalStore.shared.exposureConfiguration.data(using: .utf8)!

        do {
            let codableExposureConfiguration = try JSONDecoder().decode(CodableExposureConfiguration.self, from: dataFromServer)
            var exposureConfigurationList = [ENExposureConfiguration]()
            for attenuationDurationThresholds in codableExposureConfiguration.attenuationDurationThresholdList {
                let exposureConfiguration = ENExposureConfiguration()
                exposureConfiguration.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
                exposureConfiguration.attenuationLevelValues = codableExposureConfiguration.attenuationLevelValues as [NSNumber]
                exposureConfiguration.daysSinceLastExposureLevelValues = codableExposureConfiguration.daysSinceLastExposureLevelValues as [NSNumber]
                exposureConfiguration.durationLevelValues = codableExposureConfiguration.durationLevelValues as [NSNumber]
                exposureConfiguration.transmissionRiskLevelValues = codableExposureConfiguration.transmissionRiskLevelValues as [NSNumber]
                exposureConfiguration.setValue(attenuationDurationThresholds, forKey: "attenuationDurationThresholds")
                
                exposureConfigurationList.append(exposureConfiguration)
                
                os_log(
                    "Got exposure configuration=%@ from server",
                    log: .en,
                    exposureConfiguration.description
                )
            }

            completion(.success(exposureConfigurationList))
        } catch {
            os_log(
                "Getting exposure configuration from server failed=%@",
                log: .en,
                type: .error,
                error as CVarArg
            )
            completion(.failure(error))
        }
    }
    
}
#endif
