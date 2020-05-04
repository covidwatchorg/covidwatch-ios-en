//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        if !userData.isOnboardingCompleted {
            return AnyView(Splash())
        } else {
            if !userData.isSetupCompleted {
                return AnyView(Setup())
            }
            else {
                return AnyView(Home())
            }
        }
    }        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
