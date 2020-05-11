//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks0: View {
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Image("Family Dancing 02")
                    .background(Image("Rectangle 33").resizable().aspectRatio(contentMode: .fill))
                    .padding(.top, .headerHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                Text("Welcome to the {UCSF Health Covid Watch} App")
                    .modifier(HowItWorksTitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 2 * .standardSpacing)
                
                Text("Welcome Text. Aliquet urna feugiat donec dictum. Massa dignissim commodo ut et. Massa dignissim commodo ut et.")
                    .modifier(HowItWorksSubtitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 32 + .standardSpacing)
            }
        }
    }
}

struct HowItWorks0_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks0()
    }
}
