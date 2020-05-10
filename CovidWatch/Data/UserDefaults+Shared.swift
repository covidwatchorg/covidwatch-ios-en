//
//  Created by Zsombor Szabo on 04/07/2018.
//

import Foundation
import CryptoKit

extension UserDefaults {        
    
    public struct Key {
        public static let lastFetchDate = "lastFetchDate"            
    }
    
    @objc dynamic public var lastFetchDate: Date? {
        return object(forKey: Key.lastFetchDate) as? Date
    }
}
