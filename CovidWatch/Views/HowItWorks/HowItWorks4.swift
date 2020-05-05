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
            
            Text("How It Works".uppercased())
                .modifier(HowItWorksSubtitleText())
                .padding(.top, .headerHeight + 2 * .standardSpacing)
            
            Text("Safer Community")
                .modifier(HowItWorksTitleText())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("How it Works 04")
            
            Text("Both Jane and Sam just helped their communities stay safe by using Covid Watch and following local healthcare guidelines for COVID-19. They share the app with friends and family so that they can help, too.")
                .modifier(HowItWorksSubtitleText())
                .padding(.vertical, .standardSpacing)
            
            if self.showsSetupButton {
                Button(action: {
                    self.userData.isOnboardingCompleted = true                
                }) {
                    Text("Setup").modifier(CallToAction())
                }.frame(minHeight: .callToActionButtonHeight)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing + 44)
                    .padding(.horizontal, 2 * .standardSpacing)
            }
        }
    }
}

struct HowItWorks4_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks4()
    }
}
