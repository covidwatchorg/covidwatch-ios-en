//
//  Created by Zsombor Szabo on 10/07/2020.
//  
//

import SwiftUI

struct RegionSelection: View {

    let dismissOnFinish: Bool

    @EnvironmentObject var localStore: LocalStore

    @State private var selectedRegionIndex: Int

    @State var isShowingNextStep = false

    @State var isShowingContinue = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(selectedRegionIndex: Int?, dismissOnFinish: Bool = false) {
        self._selectedRegionIndex = .init(initialValue: selectedRegionIndex != nil ? selectedRegionIndex! + 1 : 0)
        self.dismissOnFinish = dismissOnFinish
    }

    var body: some View {

        VStack {
            if !isShowingNextStep {
                regionSelection.transition(.slide)
            } else {
                Setup3().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }

    var regionSelection: some View {

        ZStack(alignment: .top) {

            Color("Tint Color")
                .edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Image("Covid Watch Logo Stacked White")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .accessibility(label: Text("COVID_WATCH_LOGO_STACKED_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.top, 2 * .standardSpacing)

                    Spacer().frame(height: 2 * .standardSpacing)

                    Text("SPLASH_MESSAGE")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer().frame(height: .standardSpacing)

                    Picker("SELECT_REGION", selection: $selectedRegionIndex) {
                        ForEach(0 ..< self.localStore.regions.count + 1) {
                            Text(verbatim: $0 != 0 ? self.localStore.regions[($0) - 1].name : NSLocalizedString("SELECT_REGION", comment: ""))
                                .font(.custom("Montserrat-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .onReceive([self.selectedRegionIndex].publisher.first()) { _ in
                        self.isShowingContinue = (self.selectedRegionIndex != 0)
                    }
                    .padding(.horizontal, -2 * .standardSpacing) // Yes, -2 * .standardSpacing
                    .preferredColorScheme(.dark)
                    .labelsHidden()

                    Text("REGION_SELECTION_PRIVACY_DISCLAIMER")
                        .font(.custom("Montserrat-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .animation(.none)

                    Spacer().frame(height: .standardSpacing)

                    if isShowingContinue {
                        Button(action: {
                            self.localStore.region = self.localStore.regions[self.selectedRegionIndex - 1]
                            withAnimation {
                                if self.dismissOnFinish {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.isShowingNextStep = true
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
