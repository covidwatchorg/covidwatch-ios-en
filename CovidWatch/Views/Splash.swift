//
//  Created by Zsombor Szabo on 04/05/2020.
//

import SwiftUI

struct Splash: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var showHowItWorks = false
    
    var body: some View {
        VStack {
            if self.showHowItWorks {
                HowItWorks().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                self.splash.transition(.slide)
            }
        }
    }
    
    var splash: some View {
        
        ZStack(alignment: .top) {
            
            Color("Tint Color")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    Image("Generic Public Health Department")
                        .accessibility(label: Text("GENERIC_PUBLIC_HEALTH_DEPARTMENT_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                                        
                    Image("People Network")
                        .accessibility(label: Text("SPLASH_IMAGE_ACCESSIBILITY_LABEL"))
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("SPLASH_MESSAGE")
                        .font(.custom("Montserrat-SemiBold", size: 21))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Button(action: {
                        withAnimation() {
                            self.showHowItWorks = true
                        }
                    }) {
                        
                        Text("GET_STARTED")
                            .font(.custom("Montserrat-Bold", size: 24))
                            .frame(maxWidth: .infinity, minHeight: .callToActionButtonHeight)
                            .foregroundColor(Color("Tint Color"))
                            .background(Color.white)
                            .cornerRadius(.callToActionButtonCornerRadius, antialiased: true)
                        
                    }.padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Image("Powered By CW")
                        .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.bottom, .standardSpacing)
                }
            }
        }
    }
}

struct Splash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
    }
}
