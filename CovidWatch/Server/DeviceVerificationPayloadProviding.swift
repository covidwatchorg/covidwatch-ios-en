//
//  Created by Zsombor Szabo on 24/06/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation

public protocol DeviceVerificationPayloadProviding {
    func generatePayload(completionHandler completion: @escaping (Data?, Error?) -> Void)
}

extension DCDevice : DeviceVerificationPayloadProviding {
    public func generatePayload(completionHandler completion: @escaping (Data?, Error?) -> Void) {
        return self.generateToken(completionHandler: completion)
    }
}
