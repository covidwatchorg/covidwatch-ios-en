//
//  Created by Zsombor Szabo on 19/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct PastDiagnosisRow: View {

    let diagnosis: Diagnosis

    let isExpanded: Bool

    var body: some View {
        HStack(spacing: 0) {

            HStack(alignment: .center, spacing: .standardSpacing) {
                Image("Past Diagnosis Row Checkmark")

                VStack(alignment: .leading) {
                    Text("VERIFIED_POSITIVE_TITLE")
                        .font(.custom("Montserrat-Bold", size: 14))
                        .foregroundColor(Color("Diagnosis Verified Color"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Group {
                        Text("SUBMIT_DATE") +
                            Text(" ") +
                            Text(verbatim: diagnosis.submitDate == nil ? NSLocalizedString("N/A", comment: "") : DateFormatter.localizedString(from: diagnosis.submitDate!, dateStyle: .medium, timeStyle: .none))
                    }
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if self.isExpanded {
                Image("Arrow Up")
            } else {
                Image("Arrow Down")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }
}

//struct PastDiagnosisRow_Previews: PreviewProvider {
//    static var previews: some View {
//        PastDiagnosisRow()
//    }
//}
