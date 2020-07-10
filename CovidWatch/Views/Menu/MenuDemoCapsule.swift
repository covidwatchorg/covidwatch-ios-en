//
//  Created by Zsombor Szabo on 04/07/2020.
//  
//

import SwiftUI

struct MenuDemoCapsule: View {
    var body: some View {
        Text("DEMO")
            .font(.custom("Montserrat-ExtraBold", size: 10))
            .foregroundColor(.white)
            .frame(minWidth: 54, minHeight: 33, alignment: .center)
            .background(Capsule(style: .circular).foregroundColor(Color.init(red: 0.173, green: 0, blue: 0.482)))
    }
}

struct MenuDemoCapsule_Previews: PreviewProvider {
    static var previews: some View {
        MenuDemoCapsule()
    }
}
