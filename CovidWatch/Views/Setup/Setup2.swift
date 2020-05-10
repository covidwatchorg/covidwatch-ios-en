//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Setup2: View {
    
    @EnvironmentObject var userData: UserData
    
    var dismissesAutomatically: Bool
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(dismissesAutomatically: Bool = false) {
        self.dismissesAutomatically = dismissesAutomatically
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    Spacer(minLength: .headerHeight)
                    
                    Text("Enable Notifications")
                        .modifier(TitleText())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Image("Phone Alerts")
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("Enable notifications to receive alerts if you have come into contact with a confirmed case of COVID-19 even when you are not using the app.")
                        .modifier(SubtitleText())
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: .stickyFooterHeight + .standardSpacing)
                    
                }                
            }
            
            VStack {
                
                Button(action: {
                    
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .sound, .badge],
                        completionHandler: { (granted, error) in
                            
                            DispatchQueue.main.async {
                                if let error = error {
                                    UIApplication.shared.topViewController?.present(error as NSError, animated: true)
                                    return
                                }
                                
                                self.userData.isNotificationsConfigured = true
                                self.userData.isSetupCompleted = true
                                
                                if self.dismissesAutomatically {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                    })
                    
                }) {
                    
                    Text("Enable").modifier(SmallCallToAction())
                    
                }.frame(minHeight: .callToActionSmallButtonHeight)
                    .padding(.top, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)

                Button(action: {
                    
                    self.userData.isNotificationsConfigured = true
                    self.userData.isSetupCompleted = true
                    
                    if self.dismissesAutomatically {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    
                    Text("Not Now")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                }.frame(minHeight: .callToActionSmallButtonHeight)
                    .padding(.top, 5)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)

            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .stickyFooterHeight, alignment: .topLeading)
            .background(BlurView(style: .systemChromeMaterial).edgesIgnoringSafeArea(.all))
        }
    }
}

struct Setup2_Previews: PreviewProvider {
    static var previews: some View {
        Setup2()
    }
}
