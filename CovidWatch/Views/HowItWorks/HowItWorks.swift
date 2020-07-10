//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks: View {

    let showsSetupButton: Bool

    let showsDismissButton: Bool

    init(showsSetupButton: Bool = true, showsDismissButton: Bool = false) {
        self.showsSetupButton = showsSetupButton
        self.showsDismissButton = showsDismissButton
    }

    var body: some View {

        ZStack(alignment: .top) {

            PageView([
                AnyView(HowItWorks1()).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading),
                AnyView(HowItWorks2()).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading),
                AnyView(HowItWorks3()).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading),
                AnyView(HowItWorks4(showsSetupButton: showsSetupButton)).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            ])

            HeaderBar(showMenu: false, showDismissButton: showsDismissButton)
        }
    }
}

struct HowItWorks_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks()
    }
}
