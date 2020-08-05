//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks4: View {

    @EnvironmentObject var localStore: LocalStore

    let showsSetupButton: Bool

    init(showsSetupButton: Bool = true) {
        self.showsSetupButton = showsSetupButton
    }

    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {

                Spacer(minLength: .headerHeight + .standardSpacing)

                HowItWorksTitleText(text: Text(verbatim: NSLocalizedString("HOW_IT_WORKS_TITLE", comment: "").uppercased()))

                HowItWorksSubtitleText(text: Text("HOW_IT_WORKS_4_SUBTITLE"))

                Spacer(minLength: .standardSpacing)

                Image("How it Works 4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibility(label: Text("HOW_IT_WORKS_4_IMAGE_ACCESSIBILITY_LABEL"))
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer(minLength: .standardSpacing)

                HowItWorksMessageText(text: Text("HOW_IT_WORKS_4_MESSAGE"))

                if self.showsSetupButton {

                    Spacer(minLength: 2 * .standardSpacing)

                    Button(action: {
                        withAnimation {
                            self.localStore.isOnboardingCompleted = true
                        }
                    }) {

                        Text("CONTINUE_SETUP").modifier(SmallCallToAction())

                    }.padding(.horizontal, 2 * .standardSpacing)

                }

                Spacer(minLength: .footerHeight + .standardSpacing)
            }
        }
    }
}

struct HowItWorks4_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks4()
    }
}
