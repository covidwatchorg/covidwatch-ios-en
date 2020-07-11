//
//  Created by Zsombor Szabo on 10/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension CodableRegion {

    static let all: [CodableRegion] = [
        `default`,
        universityOfArizona
    ]

    static let `default`: Self = .init(
        name: "Arizona State",
        logoTypeImageName: "Public Health Authority Logotype - Arizona State",
        logoImageName: "Public Health Authority Logo - Arizona State",
        website: "https://www.azdhs.gov"
    )

    static let universityOfArizona: Self = .init(
        name: "University of Arizona",
        logoTypeImageName: "Public Health Authority Logotype - University of Arizona",
        logoImageName: "Public Health Authority Logo - University of Arizona",
        website: "https://www.arizona.edu"
    )

}
