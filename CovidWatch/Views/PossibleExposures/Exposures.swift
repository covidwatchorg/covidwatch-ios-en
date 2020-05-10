//
//  Created by Zsombor Szabo on 08/05/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct PossibleExposures: View {
    
    let exposures: [Exposure]
    
    @State private var showGreeting = true
    
    @State private var isShowingExposureDetail = false
    
    init(exposures: [Exposure]) {
        self.exposures = exposures
        UITableView.appearance().backgroundColor = .systemBackground
    }
    
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
                    
                    Toggle(isOn: $showGreeting) {
                        Text("Exposure Notifications")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .foregroundColor(Color("Title Text Color"))
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .padding(.top, 2 * .standardSpacing)
                    
                    Spacer(minLength: .standardSpacing)
                    
                    Text("You will be notified if you are exposed to COVID-19.")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("Title Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                    
                    Spacer(minLength: 2 * .standardSpacing)
                    
                    Text("Exposure last checked today at 3:15pm.")
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .background(Color("Possible Exposures Last Check Background Color"))
                    
                    ForEach(0..<self.exposures.count) { index in
                        
                        Button(action: {
                            self.isShowingExposureDetail.toggle()
                        }) {
                            ExposureRow(
                                exposure: self.exposures[0]
                            )
                            .padding(.horizontal, 2 * .standardSpacing)
                        }
                        .sheet(isPresented: self.$isShowingExposureDetail) { PossibleExposure(exposure: self.exposures[index]) }
                        .background(index % 2 == 0 ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                        .frame(minHeight: 54)
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
        PossibleExposures(exposures: [
            Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max),
            Exposure(date: Date().addingTimeInterval(-60*60*24*2), duration: 60*15, totalRiskScore: 3, transmissionRiskLevel: .max)
        ])
    }
}
