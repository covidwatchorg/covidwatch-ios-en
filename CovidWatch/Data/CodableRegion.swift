//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import Foundation

public struct CodableRegion: Codable {

    public enum NextStepType: Int, Codable {
        case phone
        case website
        case getTestedDates
    }

    public struct NextStep: Codable {
        let type: NextStepType
        let url: String
        let description: String
    }

    let name: String
    var logoTypeImageName: String
    var logoImageName: String
    let website: String
    let riskLowThreshold: Float = 0.14
    let riskHighThreshold: Float = 3.00
    let nextStepsRiskLow: [NextStep]
}
