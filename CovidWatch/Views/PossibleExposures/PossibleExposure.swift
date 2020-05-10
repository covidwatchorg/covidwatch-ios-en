//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI

struct PossibleExposure: View {
    
    @EnvironmentObject var localStore: LocalStore
    
    @State var isShowingReporting: Bool = false
    
    let exposure: Exposure
    
    init(exposure: Exposure) {
        self.exposure = exposure
    }

    var body: some View {
        
        ZStack(alignment: .top) {
                        
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    Text("Possible Exposure")
                        .font(.custom("Montserrat-SemiBold", size: 31))
                        .foregroundColor(Color("Alert Background Critical Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, .headerHeight)
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Text("Details")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(Color("Title Text Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text("You were near someone who has shared a positive and verified diagnosis of COVID-19.")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                                        
                    PossibleExposureTable(exposure: self.exposure)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.top, .standardSpacing)
                        .padding(.bottom, .standardSpacing)
                    
                    Text("Next Steps")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(Color("Title Text Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text("• Varius non, quis fermentum, feugiat maecenas eu.")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                        
                    Spacer(minLength: .standardSpacing)
                    
                    VStack(spacing: 0) {
                        
                        Text("Got a positive diagnosis? Share it anonymously to help your community stay safe.")
                            .modifier(SubCallToAction())
                            .padding(.horizontal, 2 * .standardSpacing)
                        
                        Button(action: {
                            self.isShowingReporting.toggle()
                        }) {
                            Text("Notify Others").modifier(SmallCallToAction())
                        }.frame(minHeight: .callToActionSmallButtonHeight)
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.bottom, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            .sheet(isPresented: $isShowingReporting) {
                                Reporting().environmentObject(self.localStore)
                        }
                        
                        Button(action: {
                            // TODO
                        }) {
                            Text("Find COVID-19 Test Site")
                                .modifier(SmallCallToAction())
                        }.frame(minHeight: .callToActionSmallButtonHeight)
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                        
                        Image("Powered By CW Grey")
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing)
                    }
                }
            }
            
            HeaderBar(showMenu: false, showDismissButton: true)
        }
    }
}

struct PossibleExposure_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposure(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
    }
}
