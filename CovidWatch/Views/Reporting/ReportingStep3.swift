//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI

struct ReportingStep3: View {

    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {

                Spacer(minLength: .headerHeight + .standardSpacing)

                Text("REPORTING_FINISH_TITLE")
                    .modifier(StandardTitleTextViewModifier())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                Spacer().frame(height: 2 * .standardSpacing)

                Text("REPORTING_FINISH_SUBTITLE_MESSAGE")
                    .font(.custom("Montserrat-Regular", size: 16))
                    .foregroundColor(Color("Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer().frame(height: 2 * .standardSpacing)

                Image("Earth")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)

                Spacer().frame(height: 2 * .standardSpacing)

                Text("REPORTING_FINISH_MESSAGE")
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2 * .standardSpacing)

                Button(action: {
                    ApplicationController.shared.handleTapShareApp()
                }) {
                    Text("SHARE_THE_APP").modifier(SmallCallToAction())
                }
                .padding(.top, 2 * .standardSpacing)
                .padding(.horizontal, 2 * .standardSpacing)

                Image("Powered By CW for HA Grey")
                    .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
            }
        }
    }
}

struct ReportingFinish_Previews: PreviewProvider {
    static var previews: some View {
        ReportingStep3()
    }
}
