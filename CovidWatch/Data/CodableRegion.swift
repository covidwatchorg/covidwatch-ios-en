//
//  Created by Zsombor Szabo on 10/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

public struct CodableRegion: Codable {

    let name: String
    var logoTypeImageName: String = ""
    var logoImageName: String = ""

    enum CodingKeys: String, CodingKey {
        case name
    }
}
