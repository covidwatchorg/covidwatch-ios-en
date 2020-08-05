//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI
import ExposureNotification

struct Setup1: View {

    let dismissesAutomatically: Bool

    @State var isShowingNextStep = false

    @EnvironmentObject var localStore: LocalStore

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(dismissesAutomatically: Bool = false) {
        self.dismissesAutomatically = dismissesAutomatically
    }

    var body: some View {

        VStack {
            if !isShowingNextStep {
                setup1.transition(.slide)
            } else {
                Setup2().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }

    var setup1: some View {

        ZStack(alignment: .top) {

            ZStack(alignment: .bottom) {

                ScrollView(.vertical, showsIndicators: false) {

                    VStack(spacing: 0) {

                        Spacer(minLength: .headerHeight + .standardSpacing)

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

                    Button(action: {

                        ExposureManager.shared.manager.setExposureNotificationEnabled(true) { (error) in

                            if let error = error {
                                ApplicationController.shared.handleExposureNotificationEnabled(error: error)
                                return
                            }

                            withAnimation {
                                self.isShowingNextStep = true
                            }

                            if self.dismissesAutomatically {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }

                    }) {

                        Text("ENABLE")
                            .modifier(SmallCallToAction())

                    }
                    .padding(.top, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)

                    Button(action: {

                        withAnimation {
                            self.isShowingNextStep = true
                        }

                        if self.dismissesAutomatically {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }) {

                        Text("NOT_NOW")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()

                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .stickyFooterHeight, alignment: .topLeading)
                .background(BlurView(style: .systemChromeMaterial).edgesIgnoringSafeArea(.all))
            }

            HeaderBar(showMenu: false)
        }
    }
}

struct Setup1_Previews: PreviewProvider {
    static var previews: some View {
        Setup1()
    }
}
