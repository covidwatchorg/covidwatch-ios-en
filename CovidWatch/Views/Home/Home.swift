//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var isShowingSettings: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                if (userData.exposureNotificationStatus != .active ||
                    userData.notificationsAuthorizationStatus != .authorized) {
                    VStack(spacing: 1) {
                        
                        if userData.exposureNotificationStatus != .active {
                            Button(action: {
                                self.isShowingSettings.toggle()
                            }) {
                                Alert(
                                    message: userData.exposureNotificationStatus.detailedDescription,
                                    backgroundColor: Color("Alert Background Normal Color")
                                )
                            }
                        }
                        
                        if userData.notificationsAuthorizationStatus != .authorized {
                            Button(action: {
                                self.isShowingSettings.toggle()
                            }) {
                                Alert(
                                    message: userData.notificationsAuthorizationStatus.detailedDescription,
                                    backgroundColor: Color("Alert Background Normal Color")
                                )
                            }
                        }
                    }.padding(.top, .headerHeight + 2 * .standardSpacing)
                }
                                
                Image("Family")
                
                if userData.isAfterSetup {
                    Text("You’re all set!")
                        .padding(.top, -2 * .standardSpacing)
                        .modifier(TitleText())
                    
                    Text("Thank you for helping protect your communities. You will be notified of potential exposure to COVID-19.")
                        .modifier(SubtitleText())
                        .padding(.vertical, .standardSpacing)
                }
                else {
                    Text("Welcome Back!")
                        .padding(.top, -2 * .standardSpacing)
                        .modifier(TitleText())
                    
                    Text("Covid Watch has not detected exposure to COVID-19. Share the app with family and friends to help your community stay safe.")
                        .modifier(SubtitleText())
                        .padding(.vertical, .standardSpacing)
                }
                
                Button(action: {
                    ApplicationController.shared.share()
                }) {
                    Text("Share the App").modifier(CallToAction())
                }.frame(minHeight: 58)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Text("It works best when everyone uses it.").modifier(SubCallToAction())
                
                Button(action: { () }) {
                    Text("Tested for COVID-19?").modifier(CallToAction())
                }.frame(minHeight: 58)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Text("Share your result anonymously to help your community stay safe.").modifier(SubCallToAction())
            }
            .sheet(isPresented: $isShowingSettings) { Settings().environmentObject(self.userData) }
            
            TopBar()                
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
