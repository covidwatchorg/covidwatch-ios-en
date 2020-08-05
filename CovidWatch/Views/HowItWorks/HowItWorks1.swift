//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks1: View {
    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {

                Spacer(minLength: .headerHeight + .standardSpacing)

                HowItWorksTitleText(text: Text(verbatim: NSLocalizedString("HOW_IT_WORKS_TITLE", comment: "").uppercased()))

                HowItWorksSubtitleText(text: Text("HOW_IT_WORKS_1_SUBTITLE"))

                Spacer(minLength: .standardSpacing)

                Image("How it Works 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibility(label: Text("HOW_IT_WORKS_1_IMAGE_ACCESSIBILITY_LABEL"))
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer(minLength: .standardSpacing)

                HowItWorksMessageText(text: Text("HOW_IT_WORKS_1_MESSAGE"))

                Spacer(minLength: .footerHeight + .standardSpacing)
            }
        }
    }
}

struct HowItWorks1_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks1()
    }
}
