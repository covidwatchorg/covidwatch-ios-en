//
//  Created by Zsombor Szabo on 10/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct RegionSelection: View {

    let dismissOnFinish: Bool

    @EnvironmentObject var userData: UserData

    @State var showSplashRegion = false

    var regions = CodableRegion.all
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

                    Spacer(minLength: 2 * .standardSpacing)

                    Text("SPLASH_MESSAGE")
                        .font(.custom("Montserrat-SemiBold", size: 21))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    VStack {
                        Picker("SELECT_REGION", selection: $selectedRegionIndex) {
                            ForEach(0 ..< self.regions.count) {
                                Text(verbatim: self.regions[$0].name)
                                    .font(.custom("Montserrat-SemiBold", size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .labelsHidden()
                    }
                    .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Text("REGION_SELECTION_PRIVACY_DISCLAIMER")
                        .font(.custom("Montserrat-SemiBold", size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Spacer(minLength: 2 * .standardSpacing)

                    Button(action: {
                        self.userData.region = self.regions[self.selectedRegionIndex]
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

                    }.padding(.horizontal, 2 * .standardSpacing)
                }
            }
        }
    }
}

//struct RegionSelection_Previews: PreviewProvider {
//    static var previews: some View {
//        RegionSelection()
//    }
//}
