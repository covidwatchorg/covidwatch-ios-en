//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

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
                        
//                        Divider()
//                        
//                        Button(action: {
//                            
////                            let exposures = (0...Int.random(in: 1...10)).map { _ -> Exposure in
////                                Exposure(date: Date(), duration: TimeInterval(Int.random(in: 1...6) * 5 * 60), totalRiskScore: UInt8.random(in: 1...8), transmissionRiskLevel: UInt8.random(in: 1...8))
////                            }
////                            self.localStore.exposures.insert(contentsOf: exposures, at: 0)
//                            self.localStore.exposures.insert(
//                                Exposure(date: Date(), duration: TimeInterval(Int.random(in: 1...6) * 5 * 60), totalRiskScore: UInt8.random(in: 1...8), transmissionRiskLevel: UInt8.random(in: 1...8)),
//                                at: 0
//                            )
//                            self.localStore.dateLastPerformedExposureDetection = Date()
//                            
//                        }) {
//                            HStack {
//                                Text("(Testing) Generate Random Exposure")
//                                Spacer()
//                                Image("Settings Button Checkmark")
//                            }.modifier(MenuTitleText())
//                        }
                        VStack(spacing: 0) {
                            
                            Divider()
                            
                            Button(action: {
                                self.localStore.exposures = []
                                self.localStore.dateLastPerformedExposureDetection = nil
                            }) {
                                HStack {
                                    Text("[DEMO] Reset Possible Exposures")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                _ = ExposureManager.shared.detectExposures(notifyUserOnError: true) { success in
                                }
                            }) {
                                HStack {
                                    Text("[DEMO] Detect Exposures from Server")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                let alertController = UIAlertController(title: NSLocalizedString("Exposure Configuration JSON", comment: ""), message: nil, preferredStyle: .alert)
                                alertController.addTextField { (textField) in
                                    textField.text = self.localStore.exposureConfiguration
                                }
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { _ in
                                    guard let json = alertController.textFields?.first?.text else { return }
                                    self.localStore.exposureConfiguration = json
                                }))
                                alertController.addAction(UIAlertAction(title: NSLocalizedString("Reset to Default", comment: ""), style: .default, handler: { _ in
                                    self.localStore.exposureConfiguration = LocalStore.exposureConfigurationDefault
                                }))
                                UIApplication.shared.topViewController?.present(alertController, animated: true)
                            }) {
                                HStack {
                                    Text("[DEMO] Set Exposure Configuration JSON")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                            
                            Button(action: {
                                let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                                let possibleExposuresPath = cachesDirectory.appendingPathComponent("Possible Exposures \(UIDevice.current.name) \(Date().timeIntervalSince1970).json")
                                do {
                                    let json = try JSONEncoder().encode(self.localStore.exposures)
                                    try json.write(to: possibleExposuresPath)
                                    let activityViewController = UIActivityViewController(activityItems: [possibleExposuresPath], applicationActivities: nil)
                                    UIApplication.shared.topViewController?.present(
                                        activityViewController,
                                        animated: true,
                                        completion: nil
                                    )
                                } catch {
                                    UIApplication.shared.topViewController?.present(
                                        error as NSError,
                                        animated: true,
                                        completion: nil
                                    )
                                }
                            }) {
                                HStack {
                                    Text("[DEMO] Export Possible Exposures")
                                }.modifier(MenuTitleText())
                            }
                            
                            Divider()
                        }
                        
                        Button(action: {
                            self.isShowingPossibleExposures.toggle()
                        }) {
                            HStack {
                                Text("Possible Exposures")
                                Spacer()
                                if (self.localStore.exposures.max(by: { $0.totalRiskScore < $1.totalRiskScore })?.totalRiskScore ?? 0 > 6) {
                                    Image("Settings Alert")
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
                                Text("Notify Others")
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingNotifyOthers) { Reporting().environmentObject(self.localStore) }
                        
                        Divider()
                        
                        Button(action: {
                            self.isShowingHowItWorks.toggle()
                        }) {
                            HStack {
                                Text("How it Works")
                            }.modifier(MenuTitleText())
                        }
                        .sheet(isPresented: $isShowingHowItWorks) { HowItWorks(showsSetupButton: false, showsDismissButton: true).environmentObject(self.userData) }
                        
                        Divider()
                        
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
                    }
                    
                    VStack(spacing: 0) {
                        
                        Divider()
                        
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
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covid-watch.org/faq") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("FAQ")
                                Spacer()
                                Image("Menu Action")
                            }.modifier(MenuTitleText())
                        }

                        Divider()
                        
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
                        
                        Divider()
                        
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
                        
                        Divider()
                        
                        Button(action: {
                            guard let url = URL(string: "https://www.covid-watch.org/support") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }) {
                            HStack {
                                Text("Get Support")
                                Spacer()
                                Image("Menu Action")
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
