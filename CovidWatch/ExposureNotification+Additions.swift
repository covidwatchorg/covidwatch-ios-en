//
//  Created by Zsombor Szabo on 26/04/2020.
//

import ExposureNotification

extension ENExposureDetectionSession {
    
    public static var current: ENExposureDetectionSession? {
        didSet {
            oldValue?.invalidate()
        }
    }
}

extension ENManager {
    
    public static let shared = ENManager()    
}
