//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks4: View {
    
    @EnvironmentObject var userData: UserData
    
    let showsSetupButton: Bool
    
    init(showsSetupButton: Bool = true) {
        self.showsSetupButton = showsSetupButton
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Spacer(minLength: .headerHeight)
                
                Text("How It Works".uppercased())
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Title Text Color"))
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Safe Communities")
                    .modifier(HowItWorksTitleText())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("How it Works 04")
                
                if self.showsSetupButton {
                    
                    Text("Jane and Sam help keep their communities safe. They share the app so that others can, too.")
                        .modifier(HowItWorksSubtitleText())
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Button(action: {
                        self.userData.isOnboardingCompleted = true
                    }) {
                        Text("Continue Setup").modifier(SmallCallToAction())
                    }.frame(minHeight: .callToActionSmallButtonHeight)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                } else {
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text("Jane and Sam help keep their communities safe. They share the app so that others can, too.")
                        .modifier(HowItWorksSubtitleText())
                        .padding(.horizontal, 2 * .standardSpacing)
                }
                
                Spacer(minLength: 4 * .standardSpacing)
            }
        }
    }
}

struct HowItWorks4_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks4()
    }
}
