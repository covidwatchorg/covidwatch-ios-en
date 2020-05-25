//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks3: View {
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Spacer(minLength: .headerHeight)
                
                Text("How It Works".uppercased())
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Title Text Color"))
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Exposure Alerts")
                    .modifier(HowItWorksTitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("How it Works 03")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer(minLength: .standardSpacing)
                
                Text("Jane’s phone gets an alert that someone she’s seen has now tested positive. The app tells her how to take action.")
                    .modifier(HowItWorksSubtitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Spacer(minLength: 3 * .standardSpacing)
            }
        }
    }
}

struct HowItWorks3_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks3()
    }
}
