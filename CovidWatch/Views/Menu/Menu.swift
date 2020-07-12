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
    
    init() {
        UITableView.appearance().backgroundColor = .systemBackground
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            Color(.white)
                .edgesIgnoringSafeArea(.top)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    Spacer(minLength: .headerHeight)
                    
                    VStack(spacing: 0) {
                        
                        Group {
                            
                            #if DEBUG
                            Divider()
                            
                            Button(action: {
                                ///   _ = ExposureManager.shared.detectExposures(notifyUserOnError: true) { _ in
                                ///}
                            }) {
                                HStack {
                                    MenuDemoCapsule()
                                    Text("DEMO_DETECT_EXPOSURES_FROM_SERVER_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                self.localStore.exposures = []
                                self.localStore.dateLastPerformedExposureDetection = nil
                                self.localStore.previousDiagnosisKeyFileURLs = []
                            }) {
                                HStack {
                                    MenuDemoCapsule()
                                    Text("DEMO_RESET_POSSIBLE_EXPOSURES_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            #endif
                            
                            #if DEBUG_CALIBRATION
                            
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
                                    MenuDemoCapsule()
                                    Text("DEMO_SET_EXPOSURE_CONFIGURATION_JSON_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                ApplicationController.shared.exportExposures()
                            }) {
                                HStack {
                                    MenuDemoCapsule()
                                    Text("DEMO_EXPORT_POSSIBLE_EXPOSURES_TITLE")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            #endif
                        }
                        
                        Divider()
                        
                        Button(action: {
                            self.isShowingPossibleExposures.toggle()
                        }) {
                            HStack {
                                Text("Possible COVID-19 Exposures")
                                Spacer()
                                if (self.localStore.exposures.max(by: { $0.totalRiskScore < $1.totalRiskScore })?.totalRiskScore ?? 0 > 6) {
                                    Image("Settings Alert")
                                        .accessibility(hidden: true)
                                }
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingPossibleExposures) {
                            Test2()
                                .environmentObject(self.userData)
                                .environmentObject(self.localStore)
                                .environmentObject(Row.init())
                        }
                        
                        Divider()
                        
                        Button(action: {
                            self.isShowingNotifyOthers.toggle()
                        }) {
                            HStack {
                                Text("Have a Positive Diagnosis?")
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingNotifyOthers) { Reporting().environmentObject(self.localStore) }
                        
                        Divider()
                        
                        Button(action: {
                            self.isShowingHowItWorks.toggle()
                        }) {
                            HStack {
                                Text("Past Positive Diagnoses")
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingHowItWorks) { HowItWorks(showsSetupButton: false, showsDismissButton: true).environmentObject(self.userData) }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/index.html") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("Change Region")
                                Spacer()
                            }.modifier(MenuTitleText())
                        }
                    }
                    Divider()
                    Color(.white)
                    VStack(spacing: 0) {
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.arizona.edu") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("Univ. of Arizona Website")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/prevent-getting-sick/prevention.html") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("CDC Health Guidelines")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covidwatch.org") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("Covid Watch Website")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                        
                        Divider()
                        
                        
                        Button(action: {
                            guard let url = URL(string: "https://covid-watch.org/how-it-works") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("How it Works")
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
                                Text("Privacy Policy")
                                Spacer()
                                Image("Menu Action")
                                    .accessibility(hidden: true)
                            }.modifier(MenuTitleText())
                        }
                        
                    }
                    Divider()
                    Button(action: {
                        guard let url = URL(string: "https://www.covidwatch.org/support") else { return }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }) {
                        HStack {
                            Text("Get Support")
                            Spacer()
                            Image("Menu Action")
                                .accessibility(hidden: true)
                        }.modifier(MenuTitleText())
                    }
                    Divider()
                    
                    Image("Powered By CW Grey")
                        .padding(.top, 8 * .standardSpacing)
                        .padding(.bottom, .standardSpacing)
                }
                .padding(.horizontal, 2 * .standardSpacing)
                
            }
            
            HeaderBarV2(showMenu: false, showDismissButton: true, logoImage: Image(""))
        }  .frame(width: 26 * .standardSpacing)
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
