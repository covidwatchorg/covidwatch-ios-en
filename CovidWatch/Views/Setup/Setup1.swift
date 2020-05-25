//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI
import ExposureNotification

struct Setup1: View {
    
    let dismissesAutomatically: Bool
    
    @EnvironmentObject var userData: UserData
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(dismissesAutomatically: Bool = false) {
        self.dismissesAutomatically = dismissesAutomatically
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                
                    Spacer(minLength: .headerHeight)
                    
                    Text("Enable Exposures")
                        .modifier(TitleText())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Image("Web 01")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("These notifications are designed to notify you if you’ve been exposed to a user who later reports themselves as testing positive for COVID-19. You can choose to turn off these notifications at any time.\n\nExposure notifications rely on the sharing and collection of random IDs. These IDs are a random string of numbers that won’t identify you to other users and change many times a day to protect your privacy.")
                        .modifier(SubtitleText())
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: .stickyFooterHeight + .standardSpacing)
                    
                }
            }
            
            VStack {
                
                Button(action: {
                    
                    ExposureManager.shared.manager.setExposureNotificationEnabled(true) { (error) in
                        
                        if let error = error {
                            ApplicationController.shared.handleExposureNotificationEnabled(error: error)
                            return
                        }
                        
                        withAnimation {
                            self.userData.isExposureNotificationSetup = true
                        }
                        
                        if self.dismissesAutomatically {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                }) {
                    
                    Text("Enable").modifier(SmallCallToAction())
                    
                }
                .padding(.top, .standardSpacing)
                .padding(.horizontal, 2 * .standardSpacing)
                
                Button(action: {
                    
                    withAnimation {
                        self.userData.isExposureNotificationSetup = true
                    }
                    
                    if self.dismissesAutomatically {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    
                    Text("Not Now")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                }
                .padding(.top, 5)
                .padding(.horizontal, 2 * .standardSpacing)
                .padding(.bottom, .standardSpacing)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .stickyFooterHeight, alignment: .topLeading)
            .background(BlurView(style: .systemChromeMaterial).edgesIgnoringSafeArea(.all))
        }
    }
}

struct Setup1_Previews: PreviewProvider {
    static var previews: some View {
        Setup1()
    }
}
