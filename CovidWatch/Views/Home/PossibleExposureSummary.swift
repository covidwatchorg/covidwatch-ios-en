//
//  Created by Zsombor Szabo on 08/05/2020.
//  
//

import SwiftUI


struct PossibleExposureSummary: View {
    
    @EnvironmentObject var localStore: LocalStore
    
    func maxTotalRiscScore() -> UInt8 {
        self.localStore.exposures.max(by: { $0.totalRiskScore < $1.totalRiskScore })?.totalRiskScore ?? 0
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                
                VStack(alignment: .leading, spacing: .standardSpacing) {
                    
                    HStack(spacing: .standardSpacing) {
                        
                        Text(verbatim: self.localStore.exposures.isEmpty ? "-" :  String(Calendar.current.dateComponents([.day], from: self.localStore.exposures.first!.date, to: Date()).day ?? 0))
                            .font(.custom("Montserrat-SemiBold", size: 48))
                            .foregroundColor(Color("Title Text Color"))
                            .frame(minWidth: 6 * .standardSpacing, alignment: .trailing)
                        
                        VStack(alignment: .leading) {
                            
                            Text("days")
                                .font(.custom("Montserrat-Bold", size: 16))
                                .foregroundColor(Color("Title Text Color"))
                            
                            Text("since last exposure")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(Color("Title Text Color"))
                            
                        }
                    }
                    
                    HStack(spacing: .standardSpacing) {
                        
                        Text(verbatim: NumberFormatter.localizedString(from: NSNumber(value: self.localStore.exposures.count), number: .decimal))
                            .font(.custom("Montserrat-SemiBold", size: 48))
                            .foregroundColor(Color("Title Text Color"))
                            .frame(minWidth: 6 * .standardSpacing, alignment: .trailing)
                        
                        VStack(alignment: .leading) {
                            
                            Text("total exposures")
                                .font(.custom("Montserrat-Bold", size: 16))
                                .foregroundColor(Color("Title Text Color"))
                            
                            Text("in the last 14 days")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(Color("Title Text Color"))
                            
                        }
                    }
                    
                    HStack(spacing: .standardSpacing) {
                        
                        Text(verbatim: String(maxTotalRiscScore()))
                            .font(.custom("Montserrat-SemiBold", size: 48))
                            .foregroundColor( maxTotalRiscScore() > 6 ?
                                Color("Alert Critical Color") : Color("Title Text Color"))
                            .frame(minWidth: 6 * .standardSpacing, alignment: .trailing)
                        
                        VStack(alignment: .leading) {
                            
                            Text("total risk score")
                                .font(.custom("Montserrat-Bold", size: 16))
                                .foregroundColor(Color("Title Text Color"))
                            
                            Text("(1-8 scale)")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(Color("Title Text Color"))
                            
                        }
                    }
                }
                
                Spacer()
                
                Image("Right Arrow-1")
            }
            .padding(.vertical, .standardSpacing)
            .padding(.leading, 2 * .standardSpacing)
            .padding(.trailing, .standardSpacing)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .border(Color("Button Border Color"), width: 1)
    }
}

//struct ExposureSummary_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//
//            PossibleExposureSummary(exposures: [])
//                .previewDisplayName("Empty")
//
//            PossibleExposureSummary(exposures: [
//                Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max),
//                Exposure(date: Date().addingTimeInterval(-60*60*24*2), duration: 60*15, totalRiskScore: 3, transmissionRiskLevel: .max)
//            ]).previewDisplayName("Default")
//
//            PossibleExposureSummary(exposures: [
//                Exposure(date: Date().addingTimeInterval(-60*60*24*2), duration: 60*15, totalRiskScore: 7, transmissionRiskLevel: .max)
//            ]).previewDisplayName("Alert")
//
//            PossibleExposureSummary(exposures:
//                (0..<1000).map { _ -> Exposure in
//                    Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max)
//                }
//            ).previewDisplayName("Many")
//
//        }.previewLayout(.fixed(width: 500, height: 270))
//
//    }
//}
