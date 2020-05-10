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
                    
                    Text("Possible Exposures")
                        .font(.custom("Montserrat-SemiBold", size: 31))
                        .foregroundColor(Color("Title Text Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, .headerHeight)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Toggle(isOn: self.$userData.isExposureNotificationEnabled) {
                        Text("Exposure Notifications")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .foregroundColor(Color("Title Text Color"))
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text(verbatim: self.userData.exposureNotificationStatus.detailedDescription)
                        .font(.custom("Montserrat-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text(verbatim: self.localStore.dateLastPerformedExposureDetection == nil ?
                        NSLocalizedString("Exposures last checked: Never", comment: "") :
                        String.localizedStringWithFormat(NSLocalizedString("Exposures last checked: %@", comment: ""), DateFormatter.localizedString(from: self.localStore.dateLastPerformedExposureDetection!, dateStyle: .short, timeStyle: .short))
                    )
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .background(Color("Possible Exposures Last Check Background Color"))
                    
                    ForEach(0..<self.localStore.exposures.count) { index in

                        Button(action: {
                            self.selectedExposure = self.localStore.exposures[index]
                            self.isShowingExposureDetail.toggle()
                        }) {
                            PossibleExposureRow(exposure: self.localStore.exposures[index])
                                .padding(.horizontal, 2 * .standardSpacing)
                        }
                        .background(index % 2 == 0 ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                        .frame(minHeight: 54)
                        .sheet(isPresented: self.$isShowingExposureDetail) {
                            PossibleExposure(exposure: self.selectedExposure!)
                                .environmentObject(self.localStore)
                        }
                    }
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("Exposure notifications are saved in this app and you can access them any time in the future.")
                        .modifier(SubCallToAction())
                        .padding(.horizontal, 2 * .standardSpacing)
                        
                    Image("Powered By CW Grey")
                        .padding(.top, 2 * .standardSpacing)
                        .padding(.bottom, .standardSpacing)
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
