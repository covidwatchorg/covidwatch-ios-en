//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    @EnvironmentObject var localStore: LocalStore
    
    var body: some View {
        VStack {
            if !userData.isOnboardingCompleted {
                Splash().transition(.slide)
            } else {
                if !userData.isSetupCompleted {
                    Setup().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    Home().transition(.move(edge: .trailing))
                }
            }
        }
    }        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
