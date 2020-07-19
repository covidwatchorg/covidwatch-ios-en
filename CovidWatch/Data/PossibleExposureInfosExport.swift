//
//  Created by Zsombor Szabo on 15/07/2020.
//  
//

import Foundation

struct PossibleExposureInfosExport: Encodable {
    let possibleExposureInfos: [CodableExposureInfo]
    let region: CodableRegion
}
