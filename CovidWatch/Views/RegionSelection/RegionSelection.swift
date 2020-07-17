//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import SwiftUI

struct RegionSelection: View {

    let dismissOnFinish: Bool

    @EnvironmentObject var userData: UserData

    @State var showSplashRegion = false

    @State private var selectedRegionIndex: Int

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            if self.showSplashRegion {
                SplashRegion().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                self.splash.transition(.slide)
            }
        }
    }

    init(selectedRegionIndex: Int, dismissOnFinish: Bool = false) {
        self._selectedRegionIndex = .init(initialValue: selectedRegionIndex)
        self.dismissOnFinish = dismissOnFinish
    }

    var splash: some View {

        ZStack(alignment: .top) {

            Color("Tint Color")
                .edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Image("Covid Watch Logo Stacked White")
                        .accessibility(label: Text("COVID_WATCH_LOGO_STACKED_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.top, 2 * .standardSpacing)

                    Spacer().frame(height: 4 * .standardSpacing)

//                    Text("SPLASH_MESSAGE")
//                        .font(.custom("Montserrat-SemiBold", size: 21))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.horizontal, 2 * .standardSpacing)
//
//                    Spacer().frame(height: .standardSpacing)

                    Group {
                        Text("SELECT_REGION")
                            .font(.custom("Montserrat-SemiBold", size: 21))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 2 * .standardSpacing)

                        Spacer().frame(height: .standardSpacing)
                    }

                    VStack(spacing: 0) {
                        Picker("SELECT_REGION", selection: $selectedRegionIndex) {
                            ForEach(0 ..< self.userData.regions.count) {
                                Text(verbatim: self.userData.regions[$0].name)
                                    .font(.custom("Montserrat-SemiBold", size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .labelsHidden()
                    }
                    .padding(.horizontal, 2 * .standardSpacing)

                    Spacer().frame(height: .standardSpacing)

                    Text("REGION_SELECTION_PRIVACY_DISCLAIMER")
                        .font(.custom("Montserrat-SemiBold", size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Spacer().frame(height: .standardSpacing)

                    Button(action: {
                        self.userData.region = self.userData.regions[self.selectedRegionIndex]
                        withAnimation {
                            if self.dismissOnFinish {
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                self.showSplashRegion = true
                            }
                        }
                    }) {

                        Text("CONTINUE")
                            .font(.custom("Montserrat-Bold", size: 18))
                            .frame(maxWidth: .infinity, minHeight: .callToActionSmallButtonHeight)
                            .foregroundColor(Color("Tint Color"))
                            .background(Color.white)
                            .cornerRadius(.callToActionSmallButtonCornerRadius, antialiased: true)

                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                }
            }
        }
        .onAppear {
            ApplicationController.shared.refreshRegions(notifyUserOnError: true)
        }
    }
}

//struct RegionSelection_Previews: PreviewProvider {
//    static var previews: some View {
//        RegionSelection()
//    }
//}
