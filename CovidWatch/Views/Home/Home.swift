//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject var userData: UserData
    
    @EnvironmentObject var localStore: LocalStore
    
    @State var isShowingExposureSettings: Bool = false
    
    @State var isShowingNotificationSettings: Bool = false
    
    @State var isShowingPossibleExposures: Bool = false
    
    @State var isShowingReporting: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 1) {
                        
                        if self.userData.showHomeWelcomeMessage {
                            Button(action: {
                                withAnimation {
                                    self.userData.showHomeWelcomeMessage = false
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
                        
                        if userData.exposureNotificationStatus != .active {
                            Button(action: {
                                
                                if self.userData.exposureNotificationStatus == .unknown ||
                                    self.userData.exposureNotificationStatus == .disabled {
                                    self.isShowingExposureSettings.toggle()
                                }
                            }) {
                                Alert(
                                    message: userData.exposureNotificationStatus.localizedDetailDescription,
                                    backgroundColor: Color("Alert Standard Color"),
                                    // swiftlint:disable:next line_length
                                    detailImage: (self.userData.exposureNotificationStatus == .unknown || self.userData.exposureNotificationStatus == .disabled) ? Image("Right Arrow") : nil
                                )
                            }
                            .sheet(isPresented: $isShowingExposureSettings) {
                                Setup1(dismissesAutomatically: true).environmentObject(self.userData)
                            }
                        }
                        if userData.notificationsAuthorizationStatus != .authorized {
                            Button(action: {
                                if self.userData.notificationsAuthorizationStatus == .denied {
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
                                    // swiftlint:disable:next line_length
                                    message: userData.notificationsAuthorizationStatus.localizedDetailDescription,
                                     // swiftlint:disable:next line_length
                                    backgroundColor: Color("Alert Standard Color")
                                )
                            }
                            .sheet(isPresented: $isShowingNotificationSettings) {
                                Setup2(dismissesAutomatically: true).environmentObject(self.userData)
                            }
                        }
                    }.padding(.top, .headerHeight)
                        // swiftlint:disable:next line_length
                        .zIndex(1) // Required for the shadow effect to be visible. Otherwise the content the follows below covers it.
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            Image("Home")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                                // swiftlint:disable:next line_length
                                //                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.263, green: 0.769, blue: 0.851, opacity: 1), Color.white.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
                                .accessibility(label: Text("HOME_IMAGE_ACCESSIBILITY_LABEL"))
                            Button(action: {
                                self.isShowingPossibleExposures.toggle()
                            }) {
                                PossibleExposureSummary()
                                    .environmentObject(self.localStore)
                            }
                            .sheet(isPresented: $isShowingPossibleExposures) {
                                Test2()
                                    .environmentObject(self.userData)
                                    .environmentObject(self.localStore)
                            }
                            Spacer(minLength: .standardSpacing)
                            Text("NOTIFY_OTHERS_CALL_TO_ACTION_MESSAGE")
                                .modifier(SubCallToAction())
                                .frame(maxWidth: .infinity)
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
                                ApplicationController.shared.handleTapShareApp()
                            }) {
                                Text("SHARE_THE_APP").modifier(SmallCallToAction())
                            }
                            .padding(.horizontal, 2 * .standardSpacing)
                            Image("Powered By CW Grey")
                                .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                                .padding(.top, 2 * .standardSpacing)
                                .padding(.bottom, .standardSpacing)
                        }
                        // swiftlint:disable:next line_length
                        //                            LinearGradient(gradient: Gradient(colors: [.init(red: 0.263, green: 0.769, blue: 0.851), .init(red: 1, green: 1, blue: 1, opacity: 0.4)]), startPoint: .top, endPoint: .bottom)
                        // swiftlint:disable:next line_length
                        //                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 10, alignment: .top)
                    }
                }
            }
            HeaderBarV2()
            if userData.isMenuOpened {
                BlurView(style: .dark)
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                Menu()
                    .environmentObject(self.userData)
                    .environmentObject(self.localStore)
                    .offset(x: 3.5 * .standardSpacing, y: 0)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Menu()
                    .environmentObject(self.userData)
                    .environmentObject(self.localStore)
                    .offset(x: 12 * .headerHeight, y: 0)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
