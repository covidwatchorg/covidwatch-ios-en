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
                                    showArror: (self.userData.exposureNotificationStatus == .unknown || self.userData.exposureNotificationStatus == .disabled)
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
                                }
                                else {
                                    self.isShowingNotificationSettings.toggle()
                                }
                                
                            }) {
                                Alert(
                                    message: userData.notificationsAuthorizationStatus.localizedDetailDescription,
                                    backgroundColor: Color("Alert Standard Color")
                                )
                            }
                            .sheet(isPresented: $isShowingNotificationSettings) {
                                Setup2(dismissesAutomatically: true).environmentObject(self.userData)
                            }
                        }
                        
                    }.padding(.top, .headerHeight)
                        .zIndex(1) // Required for the shadow effect to be visible. Otherwise the content the follows below covers it.
                    
                    ZStack(alignment: .top) {
                        
                        VStack(spacing: 0) {
                            
                            Image("Home")
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 232, alignment: .top)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.263, green: 0.769, blue: 0.851, opacity: 1), Color.white.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
                                .accessibility(label: Text("HOME_IMAGE_ACCESSIBILITY_LABEL"))
                                                        
                            Button(action: {
                                self.isShowingPossibleExposures.toggle()
                            }) {
                                PossibleExposureSummary()
                                    .environmentObject(self.localStore)
                            }
                            .padding(.horizontal, 2 * .standardSpacing)
                            .sheet(isPresented: $isShowingPossibleExposures) {
                                PossibleExposures()
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
                                ApplicationController.shared.shareApp()
                            }) {
                                Text("SHARE_THE_APP").modifier(SmallCallToAction())
                            }
                            .padding(.horizontal, 2 * .standardSpacing)
                            
                            Image("Powered By CW Grey")
                                .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                                .padding(.top, 2 * .standardSpacing)
                                .padding(.bottom, 3 * .standardSpacing)
                        }
                        
                        //                            LinearGradient(gradient: Gradient(colors: [.init(red: 0.263, green: 0.769, blue: 0.851), .init(red: 1, green: 1, blue: 1, opacity: 0.4)]), startPoint: .top, endPoint: .bottom)
                        //                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 10, alignment: .top)
                    }
                }
            }
            
            HeaderBar()
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
