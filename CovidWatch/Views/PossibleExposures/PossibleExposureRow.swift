//
//  Created by Zsombor Szabo on 09/05/2020.
//  
//

import SwiftUI

struct PossibleExposureRow: View {

    let exposure: CodableExposureInfo

    let isExpanded: Bool

    func formattedDate() -> String {
        return DateFormatter.localizedString(from: exposure.date, dateStyle: .medium, timeStyle: .none)
    }

    func accessibilityLabel() -> String {
        if exposure.totalRiskScore.level == .high {
            return String.localizedStringWithFormat(NSLocalizedString("HIGH_RISK_EXPOSURE_DATE_MESSAGE", comment: ""), formattedDate())
        } else if exposure.totalRiskScore.level == .medium {
            return String.localizedStringWithFormat(NSLocalizedString("MEDIUM_RISK_EXPOSURE_DATE_MESSAGE", comment: ""), formattedDate())
        } else {
            return String.localizedStringWithFormat(NSLocalizedString("LOW_RISK_EXPOSURE_DATE_MESSAGE", comment: ""), formattedDate())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                self.formattedDateText
                Spacer()
                #if !DIST_APP_STORE
                if self.isExpanded {
                    Image("Arrow Up")
                } else {
                    Image("Arrow Down")
                }
                #endif
            }
            .accessibility(label: Text(verbatim: accessibilityLabel()))
            .frame(maxWidth: .infinity, maxHeight: 54, alignment: .leading)
        }
    }

    var formattedDateText: Text {
        Text(" ") +
        Text(verbatim: formattedDate())
            .font(.custom("Montserrat-Semibold", size: 14))
            .foregroundColor(Color("Text Color"))
    }
}

//struct ExposureRow_Previews: PreviewProvider {
//    static var previews: some View {
//        PossibleExposureRow(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
//    }
//}
