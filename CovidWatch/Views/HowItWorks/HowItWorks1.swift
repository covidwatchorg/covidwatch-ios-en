//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks1: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            Text("How It Works".uppercased())
                .modifier(HowItWorksSubtitleText())
                .padding(.top, .headerHeight + 2 * .standardSpacing)
            
            Text("Secure Connection")
                .modifier(HowItWorksTitleText())
            
            Image("How it Works 01")
            
            Text("Sam and Jane cross paths for the first time and have a 15 minute conversation. The Covid Watch app creates a randomized key to log the interaction on both of their phones. The logs are 100% anonymous and no personal information is ever stored or saved.")
                .modifier(HowItWorksSubtitleText())
                .padding(.vertical, .standardSpacing)
        }
    }
}

struct HowItWorks1_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks1()
    }
}
