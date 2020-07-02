//
//  Created by Zsombor Szabo on 21/05/2020.
//  
//

import Foundation

extension Data {

    public static func random(count: Int) -> Data {
        var result = Data(count: count)
        _ = result.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!)
        }
        return result
    }

}
