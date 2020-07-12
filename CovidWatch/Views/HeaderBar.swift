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

    @State var isShowingRegionSelection: Bool = false

    @EnvironmentObject var userData: UserData

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

            VStack(alignment: .leading) {

                HStack {

                    Image(self.userData.region.logoImageName)
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
                                Menu()
                                    .environmentObject(self.userData)
                                    .environmentObject(self.localStore)
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
                    HStack {
                        Text("SELECTED_REGION")
                            .font(.custom("Montserrat-Semibold", size: 12))
                            .foregroundColor(Color("Title Text Color"))
                        Button(action: {
                            self.isShowingRegionSelection.toggle()
                        }) {
                            Text(self.userData.region.name)
                                .font(.custom("Montserrat-Semibold", size: 12))
                                .foregroundColor(Color("Title Text Color"))
                                .underline()
                        }.sheet(isPresented: self.$isShowingRegionSelection) {
                            RegionSelection(
                                selectedRegionIndex: self.userData.selectedRegionIndex,
                                dismissOnFinish: true
                            )
                                .environmentObject(self.userData)
                                .environmentObject(self.localStore)
                        }
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
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
