//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Setup: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            if !userData.isExposureNotificationSetup {
                Setup1().transition(.slide)
            } else {
                Setup2().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            
            HeaderBar(showMenu: false)
        }
    }
}

struct Setup_Previews: PreviewProvider {
    static var previews: some View {
        Setup()
    }
}
