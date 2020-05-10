//
//  Created by Zsombor Szabo on 09/05/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct PossibleExposureRow: View {
    
    let exposure: Exposure
    
    var body: some View {
        HStack(spacing: 18) {
            Image("Exposure Row High Risk")
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .font(.custom("Montserrat-Bold", size: 18))
                .foregroundColor(Color("Title Text Color"))
            Spacer()
            Image("Exposure Row Right Arrow")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct ExposureRow_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposureRow(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
    }
}
