//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI
import os.log

struct Home: View {

    @EnvironmentObject var localStore: LocalStore

    @State var isShowingExposureSettings: Bool = false

    @State var isShowingNotificationSettings: Bool = false

    @State var isShowingReporting: Bool = false

    @State var isShowingRegionSelection: Bool = false

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    VStack(spacing: 1) {

                        if self.localStore.showHomeWelcomeMessage {
                            Button(action: {
                                withAnimation {
                                    self.localStore.showHomeWelcomeMessage = false
                                }
                            }) {
                                Alert(
                                    message: NSLocalizedString("HOME_WELCOME_MESSAGE", comment: ""),
                                    backgroundColor: Color("Alert Standard Color"),
                                    showExclamation: false,
                                    detailImage: Image("Alert Dismiss")
                                )
                            }
                        }

                        if localStore.exposureNotificationStatus != .active {
                            Button(action: {

                                if self.localStore.exposureNotificationStatus == .unknown ||
                                    self.localStore.exposureNotificationStatus == .disabled ||
                                    self.localStore.exposureNotificationStatus == .restricted {
                                    self.isShowingExposureSettings.toggle()
                                }

                            }) {
                                Alert(
                                    message: localStore.exposureNotificationStatus.localizedDetailDescription,
                                    backgroundColor: Color("Alert Standard Color"),
                                    detailImage: (self.localStore.exposureNotificationStatus == .unknown || self.localStore.exposureNotificationStatus == .disabled ||
                                        self.localStore.exposureNotificationStatus == .restricted) ? Image("Right Arrow") : nil
                                )
                            }
                            .sheet(isPresented: $isShowingExposureSettings) {
                                    Setup1(dismissesAutomatically: true)
                                    .environmentObject(self.localStore)
                            }
                        }

                        if localStore.notificationsAuthorizationStatus != .authorized {
                            Button(action: {

                                if self.localStore.notificationsAuthorizationStatus == .denied {
                                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                                        UIApplication.shared.canOpenURL(settingsUrl) else {
                                            return
                                    }
                                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                                } else {
                                    self.isShowingNotificationSettings.toggle()
                                }

                            }) {
                                Alert(
                                    message: localStore.notificationsAuthorizationStatus.localizedDetailDescription,
                                    backgroundColor: Color("Alert Standard Color")
                                )
                            }
                            .sheet(isPresented: $isShowingNotificationSettings) {
                                Setup2(dismissesAutomatically: true)
                                    .environmentObject(self.localStore)
                            }
                        }

                    }.padding(.top, .largeHeaderHeight)
                        .zIndex(1) // Required for the shadow effect to be visible. Otherwise the content the follows below covers it.

                    ZStack(alignment: .top) {

                        VStack(spacing: 0) {

                            Image("Home")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                                .accessibility(label: Text("HOME_IMAGE_ACCESSIBILITY_LABEL"))

                            Text(verbatim: self.localStore.homeRiskLevel.description)
                                .font(.custom("Montserrat-Bold", size: 18))
                                .foregroundColor(Color.white)
                                .padding(.vertical, .standardSpacing)
                                .frame(maxWidth: .infinity, minHeight: .minTappableTargetDimension, alignment: .leading)
                                .padding(.horizontal, 2 * .standardSpacing)
                                .background(self.localStore.homeRiskLevel.color)

                            NextSteps()
                                .padding(.vertical, 2 * .standardSpacing)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.systemGray6))
                                .sheet(isPresented: $isShowingReporting) {
                                    ReportingStep1()
                                        .environmentObject(self.localStore)
                                }

                            if self.localStore.homeRiskLevel != .verifiedPositive && !self.localStore.region.isDisabled {

                                Spacer(minLength: 2 * .standardSpacing)

                                Text("NOTIFY_OTHERS_CALL_TO_ACTION_TITLE")
                                    .font(.custom("Montserrat-Semibold", size: 18))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 2 * .standardSpacing)

                                Spacer(minLength: .standardSpacing)

                                Text("NOTIFY_OTHERS_CALL_TO_ACTION_MESSAGE")
                                    .modifier(SubCallToAction())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 2 * .standardSpacing)

                                Button(action: {
                                    self.isShowingReporting.toggle()
                                }) {
                                    Text("HOME_NOTIFY_OTHERS_BUTTON").modifier(SmallCallToAction())
                                }
                                .padding(.top, 2 * .standardSpacing)
                                .padding(.bottom, .standardSpacing)
                                .padding(.horizontal, 2 * .standardSpacing)

                            } else if self.localStore.region.isDisabled {

                                Spacer(minLength: 2 * .standardSpacing)

                                Text("HOME_REGION_DISABLED_MESSAGE")
                                    .modifier(SubCallToAction())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 2 * .standardSpacing)

                                Button(action: {
                                    self.isShowingRegionSelection.toggle()
                                }) {
                                    Text("HOME_REGION_DISABLED_SELECT_OTHER").modifier(SmallCallToAction())
                                }
                                .sheet(isPresented: self.$isShowingRegionSelection) {
                                    RegionSelection(
                                        selectedRegionIndex: self.localStore.selectedRegionIndex,
                                        dismissOnFinish: true
                                    ).environmentObject(self.localStore)
                                }
                                .padding(.top, 2 * .standardSpacing)
                                .padding(.bottom, .standardSpacing)
                                .padding(.horizontal, 2 * .standardSpacing)
                            }

                            Image("Powered By CW for HA Grey")
                                .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                                .padding(.top, .standardSpacing)
                                .padding(.bottom, .standardSpacing)

                        }
                    }
                }
            }

            HeaderBar(showRegionSelection: true)
                .environmentObject(self.localStore)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
