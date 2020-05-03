//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                Image("Family")
                
                Text("Welcome Back!").modifier(TitleLabel())
                
                Text("Covid Watch has not detected exposure to COVID-19. Share the app with family and friends to help your community stay safe.").modifier(SubtitleLabel()).padding(.vertical, .standardSpacing)
                
                Button(action: { () }) {
                    Text("Share the App").modifier(CallToAction())
                }.frame(minHeight: 58)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Text("It works best when everyone uses it.").modifier(SubCallToAction())
                
                Button(action: { () }) {
                    Text("Tested for COVID-19?").modifier(CallToAction())
                }.frame(minHeight: 58)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Text("Share your result anonymously to help your community stay safe.").modifier(SubCallToAction())
            }
            
            TopBar().padding(.horizontal, 2 * .standardSpacing)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
