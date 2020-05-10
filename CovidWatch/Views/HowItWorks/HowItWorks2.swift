//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks2: View {
    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Spacer(minLength: .headerHeight)
                
                Text("How It Works".uppercased())
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Title Text Color"))
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Diagnosis Reports")
                    .modifier(HowItWorksTitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("How it Works 02")
                
                Spacer(minLength: .standardSpacing)
                
                Text("A few days later, Sam tests positive for COVID-19. He enters the verified results into the Covid Watch app.")
                    .modifier(HowItWorksSubtitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Spacer(minLength: 3 * .standardSpacing)
            }
        }
    }
}

struct HowItWorks2_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks2()
    }
}
