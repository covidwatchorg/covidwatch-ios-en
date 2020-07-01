//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import SwiftUI
import ExposureNotification

struct Setup1: View {
    let dismissesAutomatically: Bool
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    init(dismissesAutomatically: Bool = false) {
        self.dismissesAutomatically = dismissesAutomatically
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: .headerHeight)
                    // swiftlint:disable:next line_length
                    HowItWorksTitleText(text: Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("SETUP_PRE_TITLE", comment: ""), NSNumber(value: 1), NSNumber(value: 2)).uppercased()))
                    Text("ENABLE_EXPOSURE_NOTIFICATIONS_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                    Spacer(minLength: 2 * .standardSpacing)
                    Image("Setup 1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibility(label: Text("ENABLE_EXPOSURE_NOTIFICATIONS_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.horizontal, 2 * .standardSpacing)
                    Spacer(minLength: 2 * .standardSpacing)
                    Text("ENABLE_EXPOSURE_NOTIFICATIONS_MESSAGE")
                        .modifier(SetupMessageTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)
                    Spacer(minLength: .stickyFooterHeight + .standardSpacing)
                }
            }
            VStack {
                Button(action: {}) {
                    Text("ENABLE")
                        .modifier(SmallCallToAction())
                }
                .padding(.top, .standardSpacing)
                .padding(.horizontal, 2 * .standardSpacing)
                Button(action: {
                    withAnimation {
                        self.userData.isExposureNotificationSetup = true
                    }
                    if self.dismissesAutomatically {
                        self.presentationMode.wrappedValue.dismiss()
                    }}) {
                        Text("NOT_NOW")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.top, 5)
                            .padding(.horizontal, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing)
                            // swiftlint:disable:next line_length
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .stickyFooterHeight, alignment: .topLeading)
                            .background(BlurView(style: .systemChromeMaterial).edgesIgnoringSafeArea(.all))
                }
            }
        }
    }
}
struct Setup1_Previews: PreviewProvider {
    static var previews: some View {
        Setup1()
    }
}
