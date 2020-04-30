//
//  Created by Zsombor Szabo on 04/07/2018.
//

import Foundation
import CryptoKit

extension UserDefaults {        
    
    public static let shared: UserDefaults = .standard
    
    public struct Key {
        public static let lastFetchDate = "lastFetchDate"
            
        public static let registration: [String : Any] = [:]
        
        // Exposure Notification
        public static let daysSinceLastExposure = "daysSinceLastExposure"
        public static let matchedKeyCount = "matchedKeyCount"
        public static let maximumRiskScore = "maximumRiskScore"
    }
    
    @objc dynamic public var lastFetchDate: Date? {
        return object(forKey: Key.lastFetchDate) as? Date
    }
    
    @objc dynamic public var daysSinceLastExposure: Int {
        return integer(forKey: Key.daysSinceLastExposure)
    }
    
    @objc dynamic public var matchedKeyCount: UInt64 {
        return UInt64(integer(forKey: Key.matchedKeyCount))
    }
    
    @objc dynamic public var maximumRiskScore: UInt8 {
        return UInt8(integer(forKey: Key.maximumRiskScore))
    }

}
