//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var isShowingSettings: Bool = false
    
    @State var isShowingTestResults: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                if (userData.matchedKeyCount != 0 ||
                    userData.exposureNotificationStatus != .active ||
                    userData.notificationsAuthorizationStatus != .authorized) {
                    
                    VStack(spacing: 1) {
                        
                        if userData.matchedKeyCount != 0 {
                            Button(action: {
                                self.isShowingTestResults.toggle()
                            }) {
                                Alert(
                                    message: String.localizedStringWithFormat(NSLocalizedString("%d day(s) since last exposure", comment: ""), userData.daysSinceLastExposure),
                                    backgroundColor: Color("Alert Background Critical Color")
                                )
                            }
                            .sheet(isPresented: $isShowingTestResults) { TestResults().environmentObject(self.userData) }
                        }
                        
                        if userData.exposureNotificationStatus != .active {
                            Button(action: {
                                self.isShowingSettings.toggle()
                            }) {
                                Alert(
                                    message: userData.exposureNotificationStatus.detailedDescription,
                                    backgroundColor: Color("Alert Background Normal Color")
                                )
                            }
                            .sheet(isPresented: $isShowingSettings) { Settings().environmentObject(self.userData) }
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
                            .sheet(isPresented: $isShowingSettings) { Settings().environmentObject(self.userData) }
                        }
                    }
                    .padding(.top, .headerHeight + 2 * .standardSpacing)
                }
                
                if userData.isAfterSubmitReport {
                    Image("Hero Woman")
                    
                    Text("Thank you for helping your community stay safe, anonymously.")
                        .modifier(SubtitleText())
                        .padding(.vertical, .standardSpacing)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .multilineTextAlignment(.center)
                }
                else {
                    Image("Family")
                }
                
                if userData.isRightAfterSetup && !userData.isAfterSubmitReport {
                    Text("You're all set!")
                        .modifier(TitleText())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -2 * .standardSpacing)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Text("Thank you for helping protect your communities. You will be notified of potential exposure to COVID-19.")
                        .modifier(SubtitleText())
                        .padding(.vertical, .standardSpacing)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                else {
                    if !userData.isAfterSubmitReport {
                        Text("Welcome Back!")
                            .modifier(TitleText())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                    }
                    
                    if self.userData.lastReportDate != .distantPast {
                        
                        Text("You reported a postive test result for COVID-19 on \(DateFormatter.localizedString(from: self.userData.lastReportDate, dateStyle: .medium, timeStyle: .none))")
                            .modifier(SubtitleText())
                            .padding(.vertical, .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Advice()
                            .padding(.horizontal, 4 * .standardSpacing)
                        
                    }
                    else {
                        Text("Covid Watch has not detected exposure to COVID-19. Share the app with family and friends to help your community stay safe.")
                            .modifier(SubtitleText())
                            .padding(.vertical, .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                    }
                }
                
                Button(action: {
                    ApplicationController.shared.share()
                }) {
                    Text("Share the App").modifier(CallToAction())
                }.frame(minHeight: .callToActionButtonHeight)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Text("It works best when everyone uses it.")
                    .modifier(SubCallToAction())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                
                Button(action: {
                    self.isShowingTestResults.toggle()
                }) {
                    Text("Tested for COVID-19?").modifier(CallToAction())
                }.frame(minHeight: .callToActionButtonHeight)
                    .padding(.vertical, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .sheet(isPresented: $isShowingTestResults) { TestResults().environmentObject(self.userData) }
                
                Text("Share your result anonymously to help your community stay safe.")
                    .modifier(SubCallToAction())
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
            }
            
            TopBar()                
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
