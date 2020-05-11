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
                    
                    if (userData.exposureNotificationStatus != .active ||
                        userData.notificationsAuthorizationStatus != .authorized) {
                        
                        VStack(spacing: 1) {
                            
                            if userData.exposureNotificationStatus != .active {
                                Button(action: {
                                    self.isShowingExposureSettings.toggle()
                                }) {
                                    Alert(
                                        message: userData.exposureNotificationStatus.detailedDescription,
                                        backgroundColor: Color("Alert Normal Color")
                                    )
                                }
                                .sheet(isPresented: $isShowingExposureSettings) {
                                    Setup1(dismissesAutomatically: true).environmentObject(self.userData)
                                }
                            }
                            
                            if userData.notificationsAuthorizationStatus != .authorized {
                                Button(action: {
                                    self.isShowingNotificationSettings.toggle()
                                }) {
                                    Alert(
                                        message: userData.notificationsAuthorizationStatus.detailedDescription,
                                        backgroundColor: Color("Alert Normal Color")
                                    )
                                }
                                .sheet(isPresented: $isShowingNotificationSettings) {
                                    Setup2(dismissesAutomatically: true).environmentObject(self.userData)
                                }
                            }
                            
                        }.padding(.top, .headerHeight)
                    }
                    
                    ZStack(alignment: .top) {
                        
                        VStack(spacing: 0) {
                            
                            Image("Family 2")
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 232, alignment: .top)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.263, green: 0.769, blue: 0.851, opacity: 1), Color.white.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
                            
                            Text("My Possible Exposures")
                                .font(.custom("Montserrat-SemiBold", size: 24))
                                .foregroundColor(Color("Title Text Color"))
                                .padding(.horizontal, 2 * .standardSpacing)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                self.isShowingPossibleExposures.toggle()
                            }) {
                                PossibleExposureSummary()
                                    .environmentObject(self.localStore)
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 2 * .standardSpacing)
                            .sheet(isPresented: $isShowingPossibleExposures) {
                                PossibleExposures()
                                    .environmentObject(self.userData)
                                    .environmentObject(self.localStore)
                            }
                            
                            Spacer(minLength: 2 * .standardSpacing)
                            
                            Text("Got a positive diagnosis? Share it anonymously to help your community stay safe.")
                                .modifier(SubCallToAction())
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 2 * .standardSpacing)
                            
                            Button(action: {
                                self.isShowingReporting.toggle()
                            }) {
                                Text("Notify Others").modifier(SmallCallToAction())
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
                                Text("Share the App").modifier(SmallCallToAction())
                            }
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            
                            Image("Powered By CW Grey")
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
