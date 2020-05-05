//
//  Created by Zsombor Szabo on 05/05/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct PotentialRisk: View {
    var body: some View {
        VStack(alignment: .center, spacing: .standardSpacing) {
            Text("COVID-19")
                .font(.custom("Montserrat-Regular", size: 18))
                .foregroundColor(Color("Subtitle Text Color"))
                .multilineTextAlignment(.center)
            Text("Potential Risk")
                .font(.custom("Montserrat-Medium", size: 33))
                .foregroundColor(Color("Alert Background Critical Color"))
                .multilineTextAlignment(.center)
            Text("of infection based on your anonymous exposure log")
                .font(.custom("Montserrat-Regular", size: 14))
                .foregroundColor(Color("Subtitle Text Color"))
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // WTF?!?
            .padding(.horizontal, 18)
            .padding(.vertical, 24)
            .border(Color("Settings Button Border Color"), width: 1)
        
    }
}

struct PotentialRisk_Previews: PreviewProvider {
    static var previews: some View {
        PotentialRisk().previewLayout(.fixed(width: 300, height: 300))
    }
}
