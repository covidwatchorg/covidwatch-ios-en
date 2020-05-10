//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks1: View {
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Spacer(minLength: .headerHeight)
                
                Text("How It Works".uppercased())
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Title Text Color"))
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Always Anonymous")
                    .modifier(HowItWorksTitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("How it Works 01")
                
                Spacer(minLength: .standardSpacing)
                
                Text("While Sam and Jane chat, their phones note each others’ anonymous signals and list them securely.")
                    .modifier(HowItWorksSubtitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Spacer(minLength: 3 * .standardSpacing)
            }
        }
    }
}

struct HowItWorks1_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks1()
    }
}
