//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Menu: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var isShowingSettings: Bool = false
    
    @State var isShowingTestResults: Bool = false
    
    @State var isShowingHowItWorks: Bool = false
    
    init(){
        UITableView.appearance().backgroundColor = .systemBackground
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            List() {
                Button(action: {
                    self.isShowingSettings.toggle()
                }) {
                    HStack {
                        Text("Settings")
                        Spacer()
                        if (userData.exposureNotificationStatus != .active ||
                            userData.notificationsAuthorizationStatus != .authorized) {
                            Image("Settings Alert")
                        }
                    }.modifier(MenuTitleText())
                }
                .sheet(isPresented: $isShowingSettings) { Settings().environmentObject(self.userData) }
                .listRowBackground(Color(UIColor.systemBackground))

                Button(action: {
                    self.isShowingTestResults.toggle()
                }) {
                    HStack {
                        Text("Test Results")
                    }.modifier(MenuTitleText())
                }
                .sheet(isPresented: $isShowingTestResults) { TestResults().environmentObject(self.userData) }
                .listRowBackground(Color(UIColor.systemBackground))

                Button(action: {
                    self.isShowingHowItWorks.toggle()
                }) {
                    HStack {
                        Text("How it Works")
                    }.modifier(MenuTitleText())
                }
                .sheet(isPresented: $isShowingHowItWorks) { HowItWorks(showsSetupButton: false, showsDismissButton: true).environmentObject(self.userData) }
                .listRowBackground(Color(UIColor.systemBackground))

                Button(action: {
                    guard let url = URL(string: "https://www.covid-watch.org") else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }) {
                    HStack {
                        Text("Covid Watch Website")
                        Spacer()
                        Image("Menu Action")
                    }.modifier(MenuTitleText())
                }
                .listRowBackground(Color(UIColor.systemBackground))

                Button(action: {
                    guard let url = URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/index.html") else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }) {
                    HStack {
                        Text("Health Guidelines")
                        Spacer()
                        Image("Menu Action")
                    }.modifier(MenuTitleText())
                }
                .listRowBackground(Color(UIColor.systemBackground))

                Button(action: {
                    guard let url = URL(string: "https://www.covid-watch.org/privacy") else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }) {
                    HStack {
                        Text("Terms of Use")
                        Spacer()
                        Image("Menu Action")
                    }.modifier(MenuTitleText())
                }
                .listRowBackground(Color(UIColor.systemBackground))
                
                Button(action: {
                    guard let url = URL(string: "https://www.covid-watch.org/privacy") else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image("Menu Action")
                    }.modifier(MenuTitleText())
                }
                .listRowBackground(Color(UIColor.systemBackground))
                
            }
            .listStyle(GroupedListStyle())
            .padding(.horizontal, 2 * .standardSpacing)
            .padding(.top, 140)
            
            TopBar(showMenu: false, showDismissButton: true)            
        }
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
