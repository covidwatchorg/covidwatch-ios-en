//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI

struct PossibleExposure: View {

    @EnvironmentObject var localStore: LocalStore

    @State var isShowingReporting: Bool = false

    let exposure: Exposure

    init(exposure: Exposure) {
        self.exposure = exposure
    }

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Text("POSSIBLE_EXPOSURE_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                        .foregroundColor(Color("Alert High Color"))
                        .padding(.top, .headerHeight)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Text("DETAILS_TITLE")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(Color("Title Text Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.top, 2 * .standardSpacing)

                    Spacer(minLength: .standardSpacing)

                    Text("POSSIBLE_EXPOSURE_MESSAGE")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)

                    PossibleExposureTable(exposure: self.exposure)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.top, .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Text("NEXT_STEPS_TITLE")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(Color("Title Text Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: .standardSpacing)

                    Text("NEXT_STEPS_MESSAGE")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)

                    VStack(spacing: 0) {

                        Spacer(minLength: 2 * .standardSpacing)

                        Text("NOTIFY_OTHERS_CALL_TO_ACTION_MESSAGE")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .modifier(SubCallToAction())
                            .padding(.horizontal, 2 * .standardSpacing)

                        Button(action: {
                            self.isShowingReporting.toggle()
                        }) {
                            Text("NOTIFY_OTHERS").modifier(SmallCallToAction())
                        }
                        .padding(.top, .standardSpacing)
                        .padding(.bottom, .standardSpacing)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .sheet(isPresented: $isShowingReporting) {
                            Reporting().environmentObject(self.localStore)
                        }

                        Button(action: {
                            // TODO
                        }) {
                            Text("FIND_TEST_SITE_TITLE")
                                .modifier(SmallCallToAction())
                        }
                        .padding(.horizontal, 2 * .standardSpacing)

                        Image("Powered By CW Grey")
                            .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing)
                    }
                }
            }

            HeaderBar(showMenu: false, showDismissButton: true)
        }
    }
}

//struct PossibleExposure_Previews: PreviewProvider {
//    static var previews: some View {
//        PossibleExposure(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
//    }
//}
