//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Welcome: View {

    @EnvironmentObject var localStore: LocalStore

    @State var showHowItWorks = false

    var body: some View {
        VStack {
            if self.showHowItWorks {
                HowItWorks().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                self.welcome.transition(.slide)
            }
        }
    }

    var welcome: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Spacer(minLength: .headerHeight)

                    Image("Welcome")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibility(label: Text("WELCOME_IMAGE_ACCESSIBILITY_LABEL"))

                    Spacer(minLength: .standardSpacing)

                    HowItWorksTitleText(text: Text(verbatim: NSLocalizedString("WELCOME_TITLE", comment: "").uppercased()))

                    Text("WELCOME_APP_NAME")
                        .font(.custom("Montserrat-SemiBold", size: 23))
                        .foregroundColor(Color("Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: .standardSpacing)

                    Text("WELCOME_MESSAGE")
                        .font(.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color("Text Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Button(action: {
                        withAnimation {
                            self.showHowItWorks = true
                        }
                    }) {

                        Text("HOW_IT_WORKS_TITLE").modifier(SmallCallToAction())

                    }.padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: .standardSpacing)
                }
            }

            HeaderBar(showMenu: false)
        }

    }
}

struct HowItWorks0_Previews: PreviewProvider {
    static var previews: some View {
        Welcome()
    }
}
