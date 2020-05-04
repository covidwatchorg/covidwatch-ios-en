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
            
            Image("Splash Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Image("Covid Watch Logo - Stacked White")
                    .padding(.top, 140)
                
                Spacer()
                
                Text("Help your community stay safe, anonymously.")
                    .font(.custom("Montserrat-Medium", size: 22))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Button(action: {
                    withAnimation() {
                        self.showHowItWorks = true
                    }
                }) {
                    Text("How it Works")
                        .font(.custom("Montserrat-Bold", size: 24))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color("Title Text Color"))
                        .background(Color.white)
                        .cornerRadius(10)
                }.frame(minHeight: 58)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, 86)
            }
        }
    }
}

struct Splash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
    }
}
