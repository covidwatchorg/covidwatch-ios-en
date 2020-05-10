//
//  Created by Zsombor Szabo on 04/05/2020.
//

import SwiftUI

struct Splash: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var showHowItWorks = false
    
    var body: some View {
        if self.showHowItWorks {
            return AnyView(HowItWorks())
        } else {
            return AnyView(self.splash)
        }
    }
    
    var splash: some View {
        
        ZStack(alignment: .top) {
            
            Color("Tint Color")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    Image("California Bear")
                        .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("The power to stop COVID-19 in the palm of your hand.")
                        .font(.custom("Montserrat-SemiBold", size: 21))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
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
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color("Tint Color"))
                            .background(Color.white)
                            .cornerRadius(.buttonCornerRadius)
                        
                    }.frame(minHeight: .callToActionButtonHeight)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
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
