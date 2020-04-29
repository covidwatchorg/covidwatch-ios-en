//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

extension Data {
    
    public static func random(count: Int) -> Data {
        return Data(
            bytes: [UInt32](repeating: 0, count: count / 4).map { _ in arc4random() },
            count: count
        )
    }
    
}
