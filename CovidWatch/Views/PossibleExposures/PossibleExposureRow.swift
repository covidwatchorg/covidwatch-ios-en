//
//  Created by Zsombor Szabo on 09/05/2020.
//  
//

import SwiftUI

struct PossibleExposureRow: View {

    let exposure: Exposure

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
        HStack(spacing: 0) {
            if exposure.totalRiskScore.level == .high {
                Image("Exposure Row High Risk")
                    .padding(.trailing, .standardSpacing)
                Text("EXPOSURE_HIGH_RISK_TITLE")
                    .font(.custom("Montserrat-Bold", size: 14))
                    .foregroundColor(Color.secondary)
                    + // "+" is important here. Otherwise the sheet can not be dismissed.
                    self.formattedDateText
            } else if exposure.totalRiskScore.level == .medium {
                Image("Exposure Row Medium Risk")
                    .padding(.trailing, .standardSpacing)
                Text("EXPOSURE_MEDIUM_RISK_TITLE")
                    .font(.custom("Montserrat-Bold", size: 14))
                    .foregroundColor(Color.secondary)
                    + // "+" is important here. Otherwise the sheet can not be dismissed.
                    self.formattedDateText
            } else {
                Image("Exposure Row Low Risk")
                    .padding(.trailing, .standardSpacing)
                Text("EXPOSURE_LOW_RISK_TITLE")
                    .font(.custom("Montserrat-Bold", size: 14))
                    .foregroundColor(Color.secondary)
                    + // "+" is important here. Otherwise the sheet can not be dismissed.
                    self.formattedDateText
            }
            Spacer()
            Image("Exposure Row Right Arrow")
        }
        .accessibility(label: Text(verbatim: accessibilityLabel()))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    var formattedDateText: Text {
        Text(" ") +
        Text(verbatim: formattedDate())
            .font(.custom("Montserrat-Regular", size: 14))
            .foregroundColor(Color.secondary)
    }
}

//struct ExposureRow_Previews: PreviewProvider {
//    static var previews: some View {
//        PossibleExposureRow(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
//    }
//}
