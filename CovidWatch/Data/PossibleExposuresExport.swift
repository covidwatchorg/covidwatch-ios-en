//
//  Created by Zsombor Szabo on 15/07/2020.
//  
//

import Foundation

struct ExposureConfigurationWithExposures: Encodable {
    let exposureConfiguration: String
    let possibleExposures: [CodableExposureInfo]
}
