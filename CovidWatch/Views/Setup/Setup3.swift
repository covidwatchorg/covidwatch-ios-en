//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Setup3: View {
    
    @EnvironmentObject var userData: UserData
    
    var dismissesAutomatically: Bool
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(dismissesAutomatically: Bool = false) {
        self.dismissesAutomatically = dismissesAutomatically
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    Spacer(minLength: .headerHeight)
                    
                    Image("Family Dancing")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibility(label: Text("WELCOME_IMAGE_ACCESSIBILITY_LABEL"))
                        .background(
                            Image("Rectangle 33")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .accessibility(hidden: true)
                    )
                    
                    Text("SETUP_3_1_MESSAGE")
                        .modifier(SetupTitleTextViewModifier())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text("SETUP_3_2_MESSAGE")
                        .modifier(SetupMessageTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: .standardSpacing)
                    
                    Text("SETUP_3_3_MESSAGE")
                        .modifier(SetupMessageTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: {
                        withAnimation {
                            self.userData.showHomeWelcomeMessage = true
                            self.userData.isSetupCompleted = true
                        }
                    }) {
                        Text("SETUP_3_GO_TO_HOME").modifier(SmallCallToAction())
                    }
                    .padding(.top, .standardSpacing)
                    .padding(.bottom, .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                    
                    Button(action: {
                        ApplicationController.shared.shareApp()
                    }) {
                        Text("SHARE_THE_APP").modifier(SmallCallToAction())
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    
                    Image("Powered By CW Grey")
                        .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                        .padding(.top, 2 * .standardSpacing)
                }
            }
            
            HeaderBar(showMenu: false)
        }
    }
}

struct Setup3_Previews: PreviewProvider {
    static var previews: some View {
        Setup3()
    }
}
