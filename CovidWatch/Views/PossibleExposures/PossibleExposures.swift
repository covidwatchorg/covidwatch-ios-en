//
//  Created by Zsombor Szabo on 08/05/2020.
//  
//

import SwiftUI

struct PossibleExposures: View {
    
    @EnvironmentObject var userData: UserData
    
    @EnvironmentObject var localStore: LocalStore
    
    @State private var isShowingExposureDetail = false
    
    @State private var selectedExposure: Exposure?
    
    var body: some View {
        
        ZStack(alignment: .top) {
                        
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    Spacer(minLength: .headerHeight)
                    
                    Text("POSSIBLE_EXPOSURES_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Toggle(isOn: self.$userData.exposureNotificationEnabled) {
                        Text("EXPOSURE_NOTIFICATIONS_TITLE")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .foregroundColor(Color("Title Text Color"))
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text(verbatim: self.userData.exposureNotificationStatusMessage)
                        .font(.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text(verbatim: self.localStore.dateLastPerformedExposureDetection == nil ?
                        NSLocalizedString("EXPOSURES_LAST_CHECKED_NEVER_MESSAGE", comment: "") :
                        String.localizedStringWithFormat(NSLocalizedString("EXPOSURES_LAST_CHECKED_DATE_MESSAGE", comment: ""), DateFormatter.localizedString(from: self.localStore.dateLastPerformedExposureDetection!, dateStyle: .medium, timeStyle: .short))
                    )
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .background(Color("Possible Exposures Last Check Background Color"))
                    
                    VStack(spacing: 0) {
                        ForEach(0..<self.localStore.exposures.count) { index in
                            
                            Button(action: {
                                self.selectedExposure = self.localStore.exposures[index]
                                self.isShowingExposureDetail.toggle()
                            }) {
                                PossibleExposureRow(exposure: self.localStore.exposures[index])
                                    .padding(.horizontal, 2 * .standardSpacing)
                            }
                            .accessibility(hint: Text("SHOWS_MORE_INFO_ACCESSIBILITY_HINT"))
                            .background(index % 2 == 0 ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                            .frame(minHeight: 54)
                            .sheet(isPresented: self.$isShowingExposureDetail) {
                                PossibleExposure(exposure: self.selectedExposure!)
                                    .environmentObject(self.localStore)
                            }
                        }
                        
                        Spacer(minLength: 2 * .standardSpacing)
                        
                        Text("EXPOSURES_ARE_SAVED_MESSAGE")
                            .modifier(SubCallToAction())
                            .padding(.horizontal, 2 * .standardSpacing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image("Powered By CW Grey")
                            .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing)
                    }
                }
            }
            
            HeaderBar(showMenu: false, showDismissButton: true)
        }
    }
}

struct Exposures_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposures()
    }
}
