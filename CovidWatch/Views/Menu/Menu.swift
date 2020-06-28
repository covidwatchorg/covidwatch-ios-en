//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct ExposureConfigurationWithExposures: Encodable {
    let exposureConfiguration: String
    let possibleExposures: [Exposure]
}

struct Menu: View {
    
    @EnvironmentObject var userData: UserData
    
    @EnvironmentObject var localStore: LocalStore
    
    @State var isShowingSettings: Bool = false
    
    @State var isShowingPossibleExposures: Bool = false
    
    @State var isShowingNotifyOthers: Bool = false
    
    @State var isShowingHowItWorks: Bool = false
    
    init(){
        UITableView.appearance().backgroundColor = .systemBackground
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    Spacer(minLength: .headerHeight)
                    
                    VStack(spacing: 0) {
                        
                        #if DEBUG_CALIBRATION
                        VStack(spacing: 0) {
                            
                            Divider()
                            
                            Button(action: {
                                self.localStore.exposures = []
                                self.localStore.dateLastPerformedExposureDetection = nil
                            }) {
                                HStack {
                                    Text("DEMO_RESET_POSSIBLE_EXPOSURES_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                _ = ExposureManager.shared.detectExposures(notifyUserOnError: true) { success in
                                }
                            }) {
                                HStack {
                                    Text("DEMO_DETECT_EXPOSURES_FROM_SERVER_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                let alertController = UIAlertController(
                                    title: NSLocalizedString("EXPOSURE_CONFIGURATION_JSON_TITLE", comment: ""),
                                    message: nil,
                                    preferredStyle: .alert
                                )
                                alertController.addTextField { (textField) in
                                    textField.text = self.localStore.exposureConfiguration
                                }
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("SAVE", comment: ""), style: .default, handler: { _ in
                                    guard let json = alertController.textFields?.first?.text else { return }
                                    self.localStore.exposureConfiguration = json
                                }))
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("RESET_TO_DEFAULT", comment: ""), style: .default, handler: { _ in
                                    self.localStore.exposureConfiguration = LocalStore.exposureConfigurationDefault
                                }))
                                UIApplication.shared.topViewController?.present(alertController, animated: true)
                            }) {
                                HStack {
                                    Text("DEMO_SET_EXPOSURE_CONFIGURATION_JSON_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                ApplicationController.shared.exportExposures()                                
                            }) {
                                HStack {
                                    Text("DEMO_EXPORT_POSSIBLE_EXPOSURES_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                        }
                        #endif
                        
                        Button(action: {
                            self.isShowingPossibleExposures.toggle()
                        }) {
                            HStack {
                                Text("POSSIBLE_EXPOSURES_TITLE")
                                Spacer()
                                if (self.localStore.exposures.max(by: { $0.totalRiskScore < $1.totalRiskScore })?.totalRiskScore ?? 0 > 6) {
                                    Image("Settings Alert")
                                        .accessibility(hidden: true)
                                }
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingPossibleExposures) {
                            PossibleExposures()
                                .environmentObject(self.userData)
                                .environmentObject(self.localStore)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            self.isShowingNotifyOthers.toggle()
                        }) {
                            HStack {
                                Text("NOTIFY_OTHERS")
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingNotifyOthers) { Reporting().environmentObject(self.localStore) }
                        
                        Divider()
                        
                        Button(action: {
                            self.isShowingHowItWorks.toggle()
                        }) {
                            HStack {
                                Text("HOW_IT_WORKS_TITLE")
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingHowItWorks) { HowItWorks(showsSetupButton: false, showsDismissButton: true).environmentObject(self.userData) }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/index.html") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("HEALTH_GUIDELINES_TITLE")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                    }
                    
                    VStack(spacing: 0) {
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covidwatch.org") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("COVID_WATCH_WEBSITE_TITLE")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covidwatch.org/faq") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("FAQ_TITLE")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }

                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covidwatch.org/privacy") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("TEMS_OF_USE_TITLE")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covidwatch.org/privacy") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("PRIVACY_POLICY_TITLE")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covidwatch.org/support") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("GET_SUPPORT_TITLE")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                    }
                }
                .padding(.horizontal, 2 * .standardSpacing)
            }
            
            HeaderBar(showMenu: false, showDismissButton: true)            
        }
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
