//
//  Created by Madhava Jay on 1/5/20.
//

import Foundation

enum AppScheme: CustomStringConvertible {
    case production
    case development
    
    var description: String {
        switch self {
            case .production:
                return "Production"
            case .development:
                return "Development"
        }
    }
}

func getLocalIP() -> String {
    // sometimes the xcode ip sniff fails, in that case you can just
    // hard code it during development
    // return "192.168.176.131"
    if let localIP = Bundle.main.infoDictionary?["LocalIP"] as? String {
        return localIP
    }
    return "localhost"
}

func getAPIUrl(_ scheme: AppScheme) -> String {
    func getLocalURL() -> String {
        let localProtocol = "http://"
        let localPort = 8080
        return "\(localProtocol)\(getLocalIP()):\(localPort)"
    }
    
    switch scheme {
        case .production:
            return ""
        default:
            return getLocalURL()
    }
}

func getAppScheme() -> AppScheme {
    if let schemeName = Bundle.main.infoDictionary?["SchemeName"] as? String {
        switch schemeName {
            case "CovidWatch-prod":
                return .production
            default:
                return .development
        }
    }
    return .development
}
