//
//  Created by Zsombor Szabo on 17/07/2020.
//  
//

import SwiftUI

struct PastDiagnoses: View {

    @EnvironmentObject var localStore: LocalStore

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Spacer(minLength: .headerHeight)

                    Text("PAST_DIAGNOSES_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)

                }
            }

            HeaderBar(showMenu: false, showDismissButton: true)
                .environmentObject(self.localStore)
        }
    }
}

struct PastDiagnoses_Previews: PreviewProvider {
    static var previews: some View {
        PastDiagnoses()
    }
}
