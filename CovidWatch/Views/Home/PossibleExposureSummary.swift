//
//  Created by Zsombor Szabo on 08/05/2020.
//  
//

import SwiftUI

struct PossibleExposureSummary: View {

    @EnvironmentObject var localStore: LocalStore

    func maxTotalRiscScore() -> UInt8 {
        self.localStore.exposuresInfos.max(by: { $0.totalRiskScore < $1.totalRiskScore })?.totalRiskScore ?? 0
    }

    func daysSinceLastExposure() -> Int? {
        if self.localStore.exposuresInfos.isEmpty {
            return nil
        }
        return Calendar.current.dateComponents([.day], from: self.localStore.exposuresInfos.first!.date, to: Date()).day ?? 0
    }

    func accessibilityLabel() -> String {

        var components: [String] = []

        components.append(NSLocalizedString("HOME_POSSIBLE_EXPOSURES_SUMMARY_TITLE", comment: ""))

        if let days = daysSinceLastExposure() {
            components.append(
                String.localizedStringWithFormat(NSLocalizedString("%d days since last exposure", comment: ""), days)
            )
        } else {
            components.append(NSLocalizedString("UNKNOWN_DAYS_SINCE_LAST_EXPOSURE", comment: ""))
        }

        components.append(String.localizedStringWithFormat(NSLocalizedString("%d exposures in the last 14 days", comment: ""), self.localStore.exposuresInfos.count))

        components.append(String.localizedStringWithFormat(NSLocalizedString("HOME_TOTAL_RISK_SCORE_ACCESSIBILITY_LABEL", comment: ""), self.maxTotalRiscScore()))

        return components.joined(separator: ", ")
    }

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    var body: some View {

        VStack(spacing: 0) {

            Divider()

            Text("HOME_POSSIBLE_EXPOSURES_SUMMARY_TITLE")
                .font(.custom("Montserrat-Bold", size: 16))
                .foregroundColor(Color("Text Color"))
                .padding(.horizontal, 2 * .standardSpacing)
                .frame(maxWidth: .infinity, minHeight: .minTappableTargetDimension, alignment: .center)
                .background(Color(UIColor.systemGray6))

            Divider()

            HStack {

                VStack(alignment: .leading, spacing: .standardSpacing) {

                    HStack {

                        Text(verbatim: self.localStore.exposuresInfos.isEmpty ? "-" :  String(Calendar.current.dateComponents([.day], from: self.localStore.exposuresInfos.first!.date, to: Date()).day ?? 0))
                            .modifier(PossibleExposureSummaryValueViewModifier())
                            .background(Capsule(style: .circular).foregroundColor(Color(UIColor.systemGray2)))

                        Text("HOME_DAYS_ROW_1_LABEL")
                            .font(.custom("Montserrat-Bold", size: 13))
                            .foregroundColor(Color("Text Color"))

                            + Text(verbatim: " ") +

                            Text("HOME_DAYS_ROW_2_LABEL")
                                .font(.custom("Montserrat-Regular", size: 13))
                                .foregroundColor(Color("Text Color"))
                    }

                    HStack {

                        Text(verbatim: NumberFormatter.localizedString(from: NSNumber(value: self.localStore.exposuresInfos.count), number: .decimal))
                            .modifier(PossibleExposureSummaryValueViewModifier())
                            .background(Capsule(style: .circular).foregroundColor(Color(UIColor.systemGray2)))

                        Text("HOME_TOTAL_EXPOSURES_ROW_1_LABEL")
                            .font(.custom("Montserrat-Bold", size: 13))
                            .foregroundColor(Color("Text Color"))

                            + Text(verbatim: " ") +

                            Text("HOME_TOTAL_EXPOSURES_ROW_2_LABEL")
                                .font(.custom("Montserrat-Regular", size: 13))
                                .foregroundColor(Color("Text Color"))
                    }

                    HStack {

                        Text(verbatim: String(maxTotalRiscScore()))
                            .modifier(PossibleExposureSummaryValueViewModifier())
                            .background(Capsule(style: .circular).foregroundColor(maxTotalRiscScore().level == .high ?
                            Color("Alert High Color") : Color(UIColor.systemGray2)))

                        Text("HOME_TOTAL_RISK_SCORE_ROW_1_LABEL")
                            .font(.custom("Montserrat-Bold", size: 13))
                            .foregroundColor(Color("Text Color"))

                            + Text(verbatim: " ") +

                            Text("HOME_TOTAL_RISK_SCORE_ROW_2_LABEL")
                                .font(.custom("Montserrat-Regular", size: 13))
                                .foregroundColor(Color("Text Color"))
                    }
                }
                .padding(.horizontal, 2 * .standardSpacing)

                Spacer()

                Image("Right Arrow-1")
                    .padding(.trailing, 2 * .standardSpacing)
            }
            .padding(.vertical, .standardSpacing)

            Divider()

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .accessibilityElement(children: .combine)
            .accessibility(label: Text(verbatim: accessibilityLabel()))
            .accessibility(hint: Text("SHOWS_MORE_INFO_ACCESSIBILITY_HINT"))
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
