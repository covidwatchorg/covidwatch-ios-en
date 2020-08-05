//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks2: View {
    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {

                Spacer(minLength: .headerHeight + .standardSpacing)

                HowItWorksTitleText(text: Text(verbatim: NSLocalizedString("HOW_IT_WORKS_TITLE", comment: "").uppercased()))

                HowItWorksSubtitleText(text: Text("HOW_IT_WORKS_2_SUBTITLE"))

                Spacer(minLength: .standardSpacing)

                Image("How it Works 2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibility(label: Text("HOW_IT_WORKS_2_IMAGE_ACCESSIBILITY_LABEL"))
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer(minLength: .standardSpacing)

                HowItWorksMessageText(text: Text("HOW_IT_WORKS_2_MESSAGE"))

                Spacer(minLength: .footerHeight + .standardSpacing)
            }
        }
    }
}

struct HowItWorks2_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks2()
    }
}
