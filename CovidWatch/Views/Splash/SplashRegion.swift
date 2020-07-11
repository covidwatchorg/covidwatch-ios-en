//
//  Created by Zsombor Szabo on 10/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct SplashRegion: View {
    @EnvironmentObject var userData: UserData

    @State var showWelcome = false

    @State var showRegionSelection = false

    var body: some View {
        VStack {
            if self.showWelcome {
                Welcome().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else if showRegionSelection {
                RegionSelection(selectedRegionIndex: self.userData.selectedRegionIndex)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                    .environmentObject(self.userData)
            } else {
                self.splash.transition(.slide)
            }
        }
    }

    var splash: some View {

        ZStack(alignment: .top) {

            Color("Tint Color")
                .edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Image(self.userData.region.logoTypeImageName)
                        .accessibility(label: Text("GENERIC_PUBLIC_HEALTH_DEPARTMENT_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.top, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Image("People Network")
                        .accessibility(label: Text("SPLASH_IMAGE_ACCESSIBILITY_LABEL"))

                    Spacer(minLength: 2 * .standardSpacing)

                    Text("SPLASH_MESSAGE")
                        .font(.custom("Montserrat-SemiBold", size: 21))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Button(action: {
                        withAnimation {
                            self.showWelcome = true
                        }
                    }) {

                        Text("CONTINUE")
                            .font(.custom("Montserrat-Bold", size: 18))
                            .frame(maxWidth: .infinity, minHeight: .callToActionSmallButtonHeight)
                            .foregroundColor(Color("Tint Color"))
                            .background(Color.white)
                            .cornerRadius(.callToActionSmallButtonCornerRadius, antialiased: true)

                    }.padding(.horizontal, 2 * .standardSpacing)

                    Button(action: {

                        withAnimation {
                            self.showRegionSelection = true
                        }

                    }) {

                        Text("BACK")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .padding()

                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                }
            }
        }
    }
}

struct SplashRegion_Previews: PreviewProvider {
    static var previews: some View {
        SplashRegion()
    }
}
