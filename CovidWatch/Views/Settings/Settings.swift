//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

// TODO: Remove
struct Settings: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                Text("Settings")                    
                    .modifier(TitleText())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .paddingLargeHeight)
                    .padding(.horizontal, 2 * .standardSpacing)

                Text("The following issue(s) need to be resolved for the app to work properly.")
                    .modifier(SubtitleText())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.vertical, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)

                Button(action: {
                    if self.userData.exposureNotificationStatus == .unknown {
                        ApplicationController.shared.startExposureNotification(notifyUserOnError: true)
                    } else if self.userData.exposureNotificationStatus == .active {
                    } else if self.userData.exposureNotificationStatus == .disabled {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else if self.userData.exposureNotificationStatus == .bluetoothOff {
                    } else if self.userData.exposureNotificationStatus == .restricted {
                    }
                }) {
                    HStack {
//                        Spacer()
                        Text(verbatim: self.userData.exposureNotificationStatus.description)
                        Spacer()
                        if self.userData.exposureNotificationStatus == .active {
                            Image("Settings Button Checkmark")
                        }
                        else {
                            Image("Settings Alert")
                        }
                    }.modifier(SettingsCallToAction())
                }
                .frame(minHeight: .callToActionButtonHeight)
                    .padding(.top, 34)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)

                Text(verbatim: self.userData.exposureNotificationStatus.detailedDescription)
                    .modifier(SubCallToAction())
                    .padding(.horizontal, 2 * .standardSpacing)

                Button(action: {
                    if self.userData.notificationsAuthorizationStatus == .authorized {
                    } else if self.userData.notificationsAuthorizationStatus == .denied {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else if self.userData.notificationsAuthorizationStatus == .notDetermined {
                        (UIApplication.shared.delegate as? AppDelegate)?
                            .requestUserNotificationAuthorization(provisional: false)
                    } else if self.userData.notificationsAuthorizationStatus == .provisional {
                        (UIApplication.shared.delegate as? AppDelegate)?
                            .requestUserNotificationAuthorization(provisional: false)
                    }
                }) {
                    HStack {
                        // Spacer() // WTF: Putting this spacer in makes drag-to-dismiss not work
                        Text(verbatim: self.userData.notificationsAuthorizationStatus.description)
                        Spacer()
                        if self.userData.notificationsAuthorizationStatus == .authorized {
                            Image("Settings Button Checkmark")
                        }
                        else {
                            Image("Settings Alert")
                        }
                    }.modifier(SettingsCallToAction())
                }
                .frame(minHeight: .callToActionButtonHeight)
                    .padding(.top, 2 * .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Text(verbatim: self.userData.notificationsAuthorizationStatus.detailedDescription)
                    .modifier(SubCallToAction())
                    .padding(.horizontal, 2 * .standardSpacing)
            }
            
            HeaderBar(showMenu: false, showDismissButton: true)
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
