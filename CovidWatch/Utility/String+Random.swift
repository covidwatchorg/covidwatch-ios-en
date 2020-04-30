//
//  Created by Zsombor Szabo on 27/04/2020.
//

import Foundation

extension String {
    
    public static func random(count: Int = 16) -> String {
        let base = "abcdefghijklmnopqrstuvwxyz0123456789"
        var randomString: String = ""
        
        for _ in 0..<count {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
}
