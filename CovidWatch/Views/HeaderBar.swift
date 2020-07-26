//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct HeaderBar: View {

    let showMenu: Bool

    let showDismissButton: Bool

    let showDemoMode: Bool

    let showRegionSelection: Bool

    @State var isShowingMenu: Bool = false

    @EnvironmentObject var localStore: LocalStore

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(
        showMenu: Bool = true,
        showDismissButton: Bool = false,
        showDemoMode: Bool = true,
        showRegionSelection: Bool = false
    ) {
        self.showMenu = showMenu
        self.showDismissButton = showDismissButton
        self.showDemoMode = showDemoMode
        self.showRegionSelection = showRegionSelection
    }

    var body: some View {

        ZStack(alignment: .center) {

            BlurView(style: .systemChromeMaterial)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 0) {

                HStack {

                    Image(self.localStore.region.logoImageName)
                        .accessibility(label: Text("GENERIC_PUBLIC_HEALTH_DEPARTMENT_IMAGE_ACCESSIBILITY_LABEL"))

                    Spacer()

                    #if DEBUG_CALIBRATION
                    Text(verbatim: NSLocalizedString("DEMO_TITLE", comment: "").uppercased())
                        .font(.custom("Montserrat-Black", size: 14))
                        .foregroundColor(Color(UIColor.systemGray4))
                    Spacer()
                    #endif

                    if self.showMenu || self.showDismissButton {
                        if self.showMenu {
                            Button(action: {
                                self.isShowingMenu.toggle()
                            }) {
                                Image("Menu Button")
                                    .frame(minWidth: .minTappableTargetDimension, minHeight: .minTappableTargetDimension)
                                    .accessibility(label: Text("MENU"))
                                    .accessibility(hint: Text("MENU_ACCESSIBILITY_HINT"))
                            }.sheet(isPresented: self.$isShowingMenu) {
                                Menu().environmentObject(self.localStore)
                            }
                        }
                        if self.showDismissButton {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("Dismiss Button")
                                    .frame(minWidth: .minTappableTargetDimension, minHeight: .minTappableTargetDimension)
                                    .accessibility(label: Text("DISMISS"))
                                    .accessibility(hint: Text("DISMISS_ACCESSIBILITY_HINT"))
                            }
                        }
                    } else {
                        Spacer()
                    }

                }
                .padding(.horizontal, 2 * .standardSpacing)

                if self.showRegionSelection {
                    SelectedRegion()
                        .padding(.horizontal, 2 * .standardSpacing)
                }
            }

        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: self.showRegionSelection ? .largeHeaderHeight : .headerHeight,
            alignment: .topLeading
        )
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        HeaderBar()
    }
}
