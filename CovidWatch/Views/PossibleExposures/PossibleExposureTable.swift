//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI

struct PossibleExposureTable: View {
    
    let exposure: Exposure
    
    let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .short
        return formatter
    }()
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                HStack {
                    Spacer(minLength: 10)
                    Text("Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
                HStack {
                    Spacer(minLength: 10)
                    Text("Duration")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
//                HStack {
//                    Spacer(minLength: 10)
//                    Text("Attenuation")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer(minLength: 10)
//                }.frame(minHeight: 30, alignment: .leading)
//                    .background(Color(UIColor.secondarySystemBackground))
//                    .border(Color("Button Border Color"), width: 1)
                                
                HStack {
                    Spacer(minLength: 10)
                    Text("Transmission Risk")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
                HStack {
                    Spacer(minLength: 10)
                    Text("Total Risk")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
            }.font(.custom("Montserrat-Bold", size: 14))
            
            VStack(spacing: 0) {
                
                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: DateFormatter.localizedString(from: exposure.date, dateStyle: .medium, timeStyle: .short))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.systemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: durationFormatter.string(from: exposure.duration) ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.systemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
//                HStack {
//                    Spacer(minLength: 20)
//                    //Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("%@ db", comment: ""), exposure.) )
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer(minLength: 10)
//                }.frame(minHeight: 30, alignment: .leading)
//                    .background(Color(UIColor.systemBackground))
//                    .border(Color("Button Border Color"), width: 1)
                
                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("Level %@ of 8", comment: ""), NSNumber(value: exposure.transmissionRiskLevel)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.systemBackground))
                    .border(Color("Button Border Color"), width: 1)
                
                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("Score %@ of 8", comment: ""), NSNumber(value: exposure.totalRiskScore)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.frame(minHeight: 30, alignment: .leading)
                    .background(Color(UIColor.systemBackground))
                    .border(Color("Button Border Color"), width: 1)
                                
            }.font(.custom("Montserrat-Regular", size: 14))
        }
    }
}

struct PossibleExposureTable_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposureTable(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
    }
}
