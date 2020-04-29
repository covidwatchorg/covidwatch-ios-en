//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import CoreData

extension ManagedExposureInfo {
    
    convenience init(context: NSManagedObjectContext, exposureInfo: ENExposureInfo) {
        self.init(context: context)
        self.attenuationValue = Int16(exposureInfo.attenuationValue)
        self.date = exposureInfo.date
        self.duration = exposureInfo.duration
    }
    
}
