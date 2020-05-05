//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks2: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            Text("How It Works".uppercased())
                .modifier(HowItWorksSubtitleText())
                .padding(.top, .headerHeight + 2 * .standardSpacing)
            
            Text("Diagnosis Reports")
                .modifier(HowItWorksTitleText())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("How it Works 02")
            
            Text("Three days later Sam tests positive for COVID-19. He reports his test results to the Covid Watch app. With his consent, his log of anonymous keys for the past 14 days is shared with other Covid Watch users.")
                .modifier(HowItWorksSubtitleText())
                .padding(.vertical, .standardSpacing)
                .padding(.bottom, 3 * .standardSpacing)
        }
    }
}

struct HowItWorks2_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks2()
    }
}
