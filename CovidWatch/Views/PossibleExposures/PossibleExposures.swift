//
//  Created by Zsombor Szabo on 08/05/2020.
//  
//

import SwiftUI

struct PossibleExposures: View {

    @EnvironmentObject var localStore: LocalStore

    @State private var selectedExposure: CodableExposureInfo?

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

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

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Spacer(minLength: .headerHeight + .standardSpacing)

                    Text("POSSIBLE_EXPOSURES_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Toggle(isOn: self.$localStore.exposureNotificationEnabled) {
                        Text("EXPOSURE_NOTIFICATIONS_TITLE")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .foregroundColor(Color("Text Color"))
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: .standardSpacing)

                    Text(verbatim: self.localStore.exposureNotificationStatusMessage)
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundColor(Color("Text Color"))
                        .padding(.horizontal, 2 * .standardSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 2 * .standardSpacing)

                    Text(verbatim: self.localStore.dateLastPerformedExposureDetection == nil ?
                        NSLocalizedString("EXPOSURES_LAST_CHECKED_NEVER_MESSAGE", comment: "") :
                        String.localizedStringWithFormat(NSLocalizedString("EXPOSURES_LAST_CHECKED_DATE_MESSAGE", comment: ""), self.dateFormatter.string(from: self.localStore.dateLastPerformedExposureDetection!))
                    )
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54, alignment: .leading)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .background(Color("Possible Exposures Last Check Background Color"))

                    VStack(spacing: 0) {
                        if self.localStore.exposuresInfos.isEmpty {

                            HStack {
                                VStack(spacing: 0) {

                                    Text("POSSIBLE_EXPOSURES_NO_EXPOSURES_TITLE")
                                        .font(.custom("Montserrat-Bold", size: 13))
                                        .foregroundColor(Color("Text Color"))
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .topLeading)

                                    Text("POSSIBLE_EXPOSURES_NO_EXPOSURES_MESSAGE")
                                        .font(.custom("Montserrat-Regular", size: 13))
                                        .foregroundColor(Color("Text Color"))
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                                }
                                Spacer()
                                Image("Doctor with Heart")
                                    .accessibility(hidden: true)
                            }
                            .padding(.top, .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.4), Color(red: 0.263, green: 0.769, blue: 0.851, opacity: 1)]), startPoint: .top, endPoint: .bottom))

                        } else {

                            ForEach(self.localStore.exposuresInfos, id: \.self) { exposureInfo in

                                VStack(spacing: 0) {

                                    Button(action: {
                                        if self.selectedExposure == exposureInfo {
                                            self.selectedExposure = nil
                                        } else {
                                            self.selectedExposure = exposureInfo
                                        }
                                    }) {
                                        VStack(spacing: 0) {

                                            Divider()

                                            PossibleExposureRow(
                                                exposure: exposureInfo,
                                                isExpanded: exposureInfo == self.selectedExposure
                                            ).frame(minHeight: 54)
                                                .padding(.horizontal, 2 * .standardSpacing)

                                            if exposureInfo == self.selectedExposure {
                                                Divider()
                                            }
                                        }
                                    }
                                    .accessibility(hint: Text("SHOWS_MORE_INFO_ACCESSIBILITY_HINT"))
                                    .frame(minHeight: 54)

                                    #if !DIST_APP_STORE
                                    if exposureInfo == self.selectedExposure {

                                        ZStack(alignment: .bottom) {

                                            ZStack(alignment: .top) {

                                                VStack(alignment: .leading, spacing: 0) {

                                                    Text("EXPOSURE_INFO_DETAIL_EXPOSURE_DATA")
                                                        .font(.custom("Montserrat-Semibold", size: 13))

                                                    Spacer().frame(height: .standardSpacing)

                                                    VStack(alignment: .leading, spacing: 5) {
                                                        HStack {
                                                            Text("EXPOSURE_INFO_DETAIL_ATTENUATION_DURATIONS_TITLE")
                                                                .font(.custom("Montserrat-Medium", size: 12))

                                                            Text(verbatim: "\(exposureInfo.attenuationDurations.map({ self.duration(for: $0)}).joined(separator: ", "))")
                                                                .accessibility(label: Text(verbatim: exposureInfo.attenuationDurations.map({ self.duration(for: $0, unitStyle: .spellOut)}).joined(separator: ", ")))
                                                                .font(.custom("Montserrat-Medium", size: 12))
                                                        }

                                                        HStack {
                                                            Text("EXPOSURE_INFO_DETAIL_TRANMISSION_RISK_LEVEL_TITLE")
                                                                .font(.custom("Montserrat-Medium", size: 12))

                                                            Text(verbatim: String(exposureInfo.transmissionRiskLevel))
                                                                .font(.custom("Montserrat-Medium", size: 12))
                                                        }

                                                    }
                                                    .accessibilityElement(children: .combine)

                                                    Spacer().frame(height: 2 * .standardSpacing)

                                                    Button(action: {

                                                        guard let url = URL(string: "https://covidwatch.org/faq"),
                                                            UIApplication.shared.canOpenURL(url) else {
                                                                return
                                                        }
                                                        UIApplication.shared.open(url, completionHandler: nil)

                                                    }) {
                                                        Text("EXPOSURE_INFO_DETAIL_LEARN_MORE")
                                                            .font(.custom("Montserrat-Semibold", size: 13))
                                                    }

                                                }
                                                .padding(.vertical, 2 * .standardSpacing)
                                                .padding(.horizontal, 2 * .standardSpacing)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(UIColor.systemGray6))

                                                Image("Expandable Row Top Gradient")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .accessibility(hidden: true)
                                            }

                                            Image("Expandable Row Bottom Gradient")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .accessibility(hidden: true)
                                        }
                                    }
                                    #endif
                                }
                            }

                            Divider()
                        }

                        Group {
                            Spacer(minLength: 2 * .standardSpacing)

                            Text("EXPOSURES_ARE_SAVED_MESSAGE")
                                .font(.custom("Montserrat-Regular", size: 13))
                                .foregroundColor(Color("Text Color"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 2 * .standardSpacing)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer(minLength: .standardSpacing)
                        }
                    }
                }
            }

            HeaderBar(showMenu: false, showDismissButton: true)
                .environmentObject(self.localStore)
        }
    }
}

struct Exposures_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposures()
    }
}
