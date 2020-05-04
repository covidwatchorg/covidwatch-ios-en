//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks3: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            Text("How It Works".uppercased())
                .modifier(HowItWorksSubtitleText())
                .padding(.top, .headerHeight + 2 * .standardSpacing)
            
            Text("Exposure Notifications")
                .modifier(HowItWorksTitleText())
            
            Image("How it Works 03")
            
            Text("Jane’s Covid Watch app sees that a shared key matches her log, and the app notifies her that she may have been in contact with COVID-19 within the past 14 days. She receives tips on what to do next.")
                .modifier(HowItWorksSubtitleText())
                .padding(.vertical, .standardSpacing)
        }
    }
}

struct HowItWorks3_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks3()
    }
}
