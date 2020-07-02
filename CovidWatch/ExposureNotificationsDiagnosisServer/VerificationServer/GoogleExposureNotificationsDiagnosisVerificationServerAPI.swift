//
//  Created by Zsombor Szabo on 30/06/2020.
//  
//

import Foundation

public struct CodableVerifyCodeRequest: Codable {
    let code: String
}

public struct CodableVerifyCodeResponse: Codable {
    let testType: String
    let testDate: String
    let token: String
    let error: String

    enum CodingKeys: String, CodingKey {
        case testType = "testtype"
        case testDate = "testdate"
        case token
        case error
    }
}
