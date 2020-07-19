//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var localStore: LocalStore

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            if !localStore.isOnboardingCompleted {
                Splash().transition(.slide)
            } else {
                if !localStore.isSetupCompleted {
                    Setup1().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
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
