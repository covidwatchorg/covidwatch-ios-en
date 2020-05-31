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
                    
                    Image("Public Health Department Generic")
                        .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("The power to stop COVID-19 in the palm of your hand.")
                        .font(.custom("Montserrat-SemiBold", size: 21))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Image("People Network")
                        .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Button(action: {
                        withAnimation() {
                            self.showHowItWorks = true
                        }
                    }) {
                        
                        Text("Get Started")
                            .font(.custom("Montserrat-Bold", size: 24))
                            .frame(maxWidth: .infinity, minHeight: .callToActionButtonHeight)
                            .foregroundColor(Color("Tint Color"))
                            .background(Color.white)
                            .cornerRadius(.callToActionButtonCornerRadius, antialiased: true)
                        
                    }.padding(.horizontal, 2 * .standardSpacing)
                    
                    Image("Powered By CW")
                        .padding(.top, 2 * .standardSpacing)
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
