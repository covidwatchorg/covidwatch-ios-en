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
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    func duration(for timeInterval: TimeInterval, unitStyle: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        durationFormatter.unitsStyle = unitStyle
        guard let string = durationFormatter.string(from: timeInterval) else {
            return ""
        }
        if timeInterval == 1800 {
            return "≥" + string
        }
        return string
    }

    var body: some View {

        VStack(spacing: 0) {

            HStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 10)
                    Text("DATE_TITLE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnA())

                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: DateFormatter.localizedString(from: exposure.date, dateStyle: .medium, timeStyle: .none))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnB())
            }
            .accessibilityElement(children: .combine)

//            HStack(spacing: 0) {
//                HStack {
//                    Spacer(minLength: 10)
//                    Text("DURATION_TITLE")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer(minLength: 10)
//                }.modifier(PossibleExposureTableColumnA())
//                
//                HStack {
//                    Spacer(minLength: 20)
//                    Text(verbatim: duration(for: exposure.duration))
//                        .accessibility(label: Text(verbatim: duration(for: exposure.duration, unitStyle: .spellOut)))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer(minLength: 10)
//                }.modifier(PossibleExposureTableColumnB())
//            }
//            .accessibilityElement(children: .combine)

            HStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 10)
                    Text("ATTENUATION_DURATIONS_TITLE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnA())

                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: "[ \(exposure.attenuationDurations.map({ duration(for: $0)}).joined(separator: ", ")) ]")
                        .accessibility(label: Text(verbatim: exposure.attenuationDurations.map({ duration(for: $0, unitStyle: .spellOut)}).joined(separator: ", ")))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnB())
            }
            .accessibilityElement(children: .combine)

            #if DEBUG_CALIBRATION
            HStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 10)
                    Text("ATTENUATION_DURATION_THRESHOLDS_TITLE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnA())

                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: "[ \(exposure.attenuationDurationThresholds.map({ String($0)}).joined(separator: ", ")) ]")
                        .accessibility(label: Text(verbatim: exposure.attenuationDurationThresholds.map({ String($0)}).joined(separator: ", ")))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnB())
            }
            .accessibilityElement(children: .combine)
            #endif

//            HStack(spacing: 0) {
//                HStack {
//                    Spacer(minLength: 10)
//                    Text("ATTENUATION_TITLE")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer(minLength: 10)
//                }.modifier(PossibleExposureTableColumnA())
//
//                HStack {
//                    Spacer(minLength: 20)
//                    Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("ATTENUATION_VALUE", comment: ""), NSNumber(value: exposure.attenuationValue)))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer(minLength: 10)
//                }.modifier(PossibleExposureTableColumnB())
//            }
//            .accessibilityElement(children: .combine)

            HStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 10)
                    Text("TRANSMISSION_RISK_LEVEL_TITLE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnA())

                HStack {
                    Spacer(minLength: 20)
                    //Text(verbatim: exposure.transmissionRiskLevel.localizedTransmissionRiskLevelDescription)
                    Text(verbatim: String(exposure.transmissionRiskLevel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnB())
            }
            .accessibilityElement(children: .combine)

            HStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 10)
                    Text("TOTAL_RISK_SCORE_TITLE")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnA())

                HStack {
                    Spacer(minLength: 20)
                    Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("TOTAL_RISK_SCORE_VALUE", comment: ""), NSNumber(value: exposure.totalRiskScore)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 10)
                }.modifier(PossibleExposureTableColumnB())
            }
            .accessibilityElement(children: .combine)
        }
    }
}

//struct PossibleExposureTable_Previews: PreviewProvider {
//    static var previews: some View {
//        PossibleExposureTable(exposure: Exposure(date: Date(), duration: 60*5, totalRiskScore: 1, transmissionRiskLevel: .max))
//    }
//}
