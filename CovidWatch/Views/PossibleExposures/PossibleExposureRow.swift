//
//  Created by Zsombor Szabo on 09/05/2020.
//  
//

import SwiftUI

struct PossibleExposureRow: View {
    
    let exposure: Exposure
    
    var body: some View {
        HStack(spacing: 18) {
            Image("Exposure Row High Risk")
            Text(verbatim: DateFormatter.localizedString(from: exposure.date, dateStyle: .medium, timeStyle: .short))
                .font(.custom("Montserrat-Regular", size: 14))
                .foregroundColor(Color("Title Text Color"))
            Spacer()
            Image("Exposure Row Right Arrow")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

//struct ExposureRow_Previews: PreviewProvider {
//    static var previews: some View {
//        PossibleExposureRow(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
//    }
//}
