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
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
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
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text(verbatim: self.localStore.dateLastPerformedExposureDetection == nil ?
                        NSLocalizedString("EXPOSURES_LAST_CHECKED_NEVER_MESSAGE", comment: "") :
                        String.localizedStringWithFormat(NSLocalizedString("EXPOSURES_LAST_CHECKED_DATE_MESSAGE", comment: ""), self.dateFormatter.string(from: self.localStore.dateLastPerformedExposureDetection!))
                    )
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .background(Color("Possible Exposures Last Check Background Color"))
                    
                    VStack(spacing: 0) {
                        if self.localStore.exposures.isEmpty {
                            
                            ZStack {
                                VStack(spacing: 0) {
                                    
                                    Text("POSSIBLE_EXPOSURES_NO_EXPOSURES_TITLE")
                                        .font(.custom("Montserrat-Bold", size: 13))
                                        .foregroundColor(Color("Title Text Color"))
                                        .padding(.leading, 2 * .standardSpacing)
                                        .padding(.trailing, 108)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("POSSIBLE_EXPOSURES_NO_EXPOSURES_MESSAGE")
                                        .font(.custom("Montserrat-Regular", size: 13))
                                        .foregroundColor(Color("Title Text Color"))
                                        .padding(.leading, 2 * .standardSpacing)
                                        .padding(.trailing, 108)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Image("Doctors Security")
                                    .accessibility(hidden: true)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                            }
                        }
                        else {
                            ForEach(0..<self.localStore.exposures.count) { index in
                                
                                Button(action: {
                                    self.selectedExposure = self.localStore.exposures[index]
                                    self.isShowingExposureDetail.toggle()
                                }) {
                                    VStack(spacing: 0) {
                                        PossibleExposureRow(exposure: self.localStore.exposures[index])
                                            .padding(.horizontal, 2 * .standardSpacing)
                                        Divider()
                                    }
                                }
                                .accessibility(hint: Text("SHOWS_MORE_INFO_ACCESSIBILITY_HINT"))
                                .frame(minHeight: 54)
                                .sheet(isPresented: self.$isShowingExposureDetail) {
                                    PossibleExposure(exposure: self.selectedExposure!)
                                        .environmentObject(self.localStore)
                                }
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
