//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Setup3: View {

    @EnvironmentObject var userData: UserData

    var dismissesAutomatically: Bool

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(dismissesAutomatically: Bool = false) {
        self.dismissesAutomatically = dismissesAutomatically
    }

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Spacer(minLength: .headerHeight)

                    Image("Setup 3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibility(label: Text("SETUP_3_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: .standardSpacing)

                    Text("SETUP_3_1_MESSAGE")
                        .modifier(StandardTitleTextViewModifier())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: .standardSpacing)

                    Text("SETUP_3_2_MESSAGE")
                        .modifier(SetupMessageTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: .standardSpacing)

                    Group {
                        Button(action: {
                            withAnimation {
                                self.userData.showHomeWelcomeMessage = true
                                self.userData.isSetupCompleted = true
                            }
                        }) {
                            Text("SETUP_3_GO_TO_HOME").modifier(SmallCallToAction())
                        }
                        .padding(.horizontal, 2 * .standardSpacing)
                    }
                }
            }

            HeaderBar(showMenu: false)
        }
    }
}

struct Setup3_Previews: PreviewProvider {
    static var previews: some View {
        Setup3()
    }
}
