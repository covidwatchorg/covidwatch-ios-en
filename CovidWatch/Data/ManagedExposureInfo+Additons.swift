//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation
import CoreData
import ExposureNotification

extension ManagedExposureInfo {
    
    convenience init(context: NSManagedObjectContext, exposureInfo: ENExposureInfo) {
        self.init(context: context)
        self.attenuationValue = Int16(exposureInfo.attenuationValue)
        self.date = exposureInfo.date
        self.duration = exposureInfo.duration
        self.totalRiskScore = Int16(exposureInfo.totalRiskScore)
        self.transmissionRiskLevel = Int16(exposureInfo.transmissionRiskLevel.rawValue)
    }
    
}
