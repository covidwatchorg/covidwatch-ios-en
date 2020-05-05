//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Setup2: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            Image("Phone Alerts")
                .padding(.top, .headerHeight)
            
            Text("Receive Alerts")
                .modifier(TitleText())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2 * .standardSpacing)
            
            Text("Enable notifications to receive anonymous alerts if you have come into contact with a confirmed case of COVID-19.")
                .modifier(SubtitleText())
                .padding(.vertical, .standardSpacing)
                .padding(.horizontal, 2 * .standardSpacing)
            
            Button(action: {
                self.userData.isNotificationsConfigured = true
                self.userData.isSetupCompleted = true
                (UIApplication.shared.delegate as? AppDelegate)?
                    .requestUserNotificationAuthorization(provisional: false)
            }) {
                Text("Allow Notifications").modifier(CallToAction())
            }.frame(minHeight: .callToActionButtonHeight)
                .padding(.top, 2 * .standardSpacing)
                .padding(.bottom, .standardSpacing)
                .padding(.horizontal, 2 * .standardSpacing)
        }
    }
}

struct Setup2_Previews: PreviewProvider {
    static var previews: some View {
        Setup2()
    }
}
