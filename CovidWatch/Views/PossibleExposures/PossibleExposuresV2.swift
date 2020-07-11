//
//  PossibleExposureV2.swift
//  CWBasics
//
//  Created by Andreas Ink on 7/10/20.
//  Copyright © 2020 Andreas Ink. All rights reserved.
//
import SwiftUI

struct Test2: View {
    @EnvironmentObject var row: Row
    @State var rowNumber = 0
    @State var isOpened: [Bool] = [false]
    @State var isToggled = false
    @State var hasLoaded = false
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var localStore: LocalStore
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    // swiftlint:disable:next line_length
    @State private var exposures = [Exposure(attenuationDurations: [1], attenuationValue: 0, date: Date(), duration: 15, totalRiskScore: 1, transmissionRiskLevel: 1, attenuationDurationThresholds: [1, 2], timeDetected: Date()), Exposure(attenuationDurations: [10], attenuationValue: 10, date: Date(), duration: 15, totalRiskScore: 8, transmissionRiskLevel: 10, attenuationDurationThresholds: [1, 2], timeDetected: Date()), Exposure(attenuationDurations: [10], attenuationValue: 10, date: Date(), duration: 15, totalRiskScore: 5, transmissionRiskLevel: 5, attenuationDurationThresholds: [1, 2], timeDetected: Date())]
    @State private var selectedExposure: Exposure?
    let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    // swiftlint:disable:next line_length
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
                VStack {
                    Text("Possible Exposures")
                        .font(.custom("Montserrat-SemiBold", size: 24))
                        .foregroundColor(Color("Title Text Color"))
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .padding(.vertical, .standardSpacing)
                        .padding(.horizontal, .standardSpacing)
                    // swiftlint:disable:next line_length
                    Text("You will be notified of possible exposures to COVID-19. We recommend that this setting remain on until the national pandemic is over.")
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundColor(Color(.black))
                        .frame(maxWidth: .infinity, minHeight: .headerHeight, alignment: .leading)
                        .padding(.vertical, .standardSpacing)
                        .padding(.horizontal, .standardSpacing)
                    HStack {
                        Toggle(isOn: $isToggled) {
                            Text("Exposure Notifications")
                                .font(.custom("Montserrat-SemiBold", size: 18))
                                .foregroundColor(Color("Subtitle Text Color"))
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        }
                        Text("on")
                    } .padding(.horizontal, .standardSpacing)
                    ZStack(alignment: .center) {
                        Color("Last Checked Header Color")
                            .frame(height: .headerHeight)
                        if self.localStore.dateLastPerformedExposureDetection == nil {
                            Text("Has not recently checked for exposure")
                            .font(.custom("Montserrat-Bold", size: 14))
                                                       .foregroundColor(Color(.white))
                                                       .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                                       .padding(.horizontal, .standardSpacing)
                        } else {
                            // swiftlint:disable:next line_length
                        Text("Last checked: " + String(self.dateFormatter.string(from: self.localStore.dateLastPerformedExposureDetection ?? Date())))
                            .font(.custom("Montserrat-Bold", size: 14))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .padding(.horizontal, .standardSpacing)
                    }
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                    .onAppear() {
                        self.row.exposure = self.exposures
                        self.rowNumber = self.row.rowNumber
                        self.hasLoaded = true
                        self.isOpened = self.row.isOpen
                    }
                    if hasLoaded {
                        ForEach(0..<exposures.count) { index in
                            PossibleExposureRow(rowNumber: index)
                        }
                    }
                }
                ZStack {
                             Color(.white)
                                 .frame(height: .headerHeight, alignment: .bottom)
                                 .edgesIgnoringSafeArea(.bottom)
                     // swiftlint:disable:next line_length
                             Text("Each exposure notification is saved in this app and will be automatically deleted after 30 days.")
                                 .font(.custom("Montserrat-Regular", size: 13))
                                 .multilineTextAlignment(.center)
                                 .foregroundColor(Color(.black))
                                 .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                                 .padding(.horizontal, .standardSpacing)
                         }
            }  .padding(.top, .standardSpacing)
        }
    }
    func buttonAction(index: Int) {
        withAnimation {
            self.row.isOpen[index].toggle()
            print(index)
        }
    }

}
struct PossibleExposureRow: View {
    @EnvironmentObject var row: Row
    @State var rowNumber: Int
    @State var isOpen = false
    func formattedDate() -> String {
        return DateFormatter.localizedString(from: row.exposure[rowNumber].date, dateStyle: .medium, timeStyle: .none)
    }
    let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    // swiftlint:disable:next line_length
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
        ZStack {
            Color(.white)
                .frame(height: .headerHeight / 1.5)
            VStack {
                HStack {
                    HStack(spacing: 0) {
                        if row.exposure[rowNumber].totalRiskScore.level == .high {
                            Image("Exposure Row High Risk")
                                .padding(.trailing, .standardSpacing)
                            Text("High Risk")
                                .font(.custom("Montserrat-Bold", size: 14))
                                .foregroundColor(Color("Title Text Color"))
                                + // "+" is important here. Otherwise the sheet can not be dismissed.
                                self.formattedDateText
                        } else if row.exposure[rowNumber].totalRiskScore.level == .medium {
                            Image("Exposure Row Medium Risk")
                                .padding(.trailing, .standardSpacing)
                            Text("Medium Risk")
                                .font(.custom("Montserrat-Bold", size: 14))
                                .foregroundColor(Color("Title Text Color"))
                                + // "+" is important here. Otherwise the sheet can not be dismissed.
                                self.formattedDateText
                        } else {
                            Image("Exposure Row Low Risk")
                                .padding(.trailing, .standardSpacing)
                            Text("Low Risk")
                                .font(.custom("Montserrat-Bold", size: 14))
                                .foregroundColor(Color("Title Text Color"))
                                + // "+" is important here. Otherwise the sheet can not be dismissed.
                                self.formattedDateText
                        }
                    }
                    .font(.custom("Montserrat", size: 16))
                    .foregroundColor(Color("Title Text Color"))
                    .padding(.horizontal, .standardSpacing)
                    Spacer(minLength: .standardSpacing)
                    Button(action: {
                        withAnimation {
                            self.isOpen.toggle()
                        }
                    }) {
                        Image("down")
                            .padding(.horizontal, .standardSpacing)
                    }
                }
                if self.isOpen {
                    ZStack {
                        Color("Drop Down Color")
                            .frame(height: 12 * .standardSpacing)
                        VStack {
                            Text("Raw Data")
                                .font(.custom("Montserrat-Bold", size: 13))
                                .foregroundColor(Color("Title Text Color"))
                                .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                .padding(.horizontal, 2.2 * .standardSpacing)
                            HStack {
                                Image("bullet")
                                HStack {
                                    Text("Attenuation Durations: :")
                                        .font(.custom("Montserrat-Medium", size: 13))
                                        .frame(alignment: .leading)
                                    // swiftlint:disable:next line_length
                                    Text("[ \(row.exposure[rowNumber].attenuationDurations.map({ duration(for: $0)}).joined(separator: ", ")) ]")
                                        .frame(alignment: .leading)
                                        .font(.custom("Montserrat-Regular", size: 13))
                                        .foregroundColor(Color(.black))
                                }
                            }  .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                .padding(.horizontal, .standardSpacing)
                            HStack {
                                Image("bullet")
                                HStack {
                                    Text("Attenuation Threshold:")
                                        .font(.custom("Montserrat-Medium", size: 13))
                                        .foregroundColor(Color(.black))
                                    // swiftlint:disable:next line_length
                                    Text("[ \(row.exposure[rowNumber].attenuationDurationThresholds.map({ String($0)}).joined(separator: ", ")) ]")
                                        .frame(alignment: .leading)
                                        .font(.custom("Montserrat-Regular", size: 13))
                                        .foregroundColor(Color(.black))
                                }
                            }  .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                .padding(.horizontal, .standardSpacing)
                            HStack {
                                Image("bullet")
                                HStack {
                                    Text("Transmission Risk Level:")
                                        .font(.custom("Montserrat-Medium", size: 13))
                                        .frame(alignment: .leading)
                                    Text(String(row.exposure[rowNumber].transmissionRiskLevel))
                                        .frame(alignment: .leading)
                                        .font(.custom("Montserrat-Regular", size: 13))
                                        .foregroundColor(Color(.black))
                                }
                            }  .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                .padding(.horizontal, .standardSpacing)
                            Button(action: {
                            }) {
                                Text("Learn More")
                                    .font(.custom("Montserrat-Medium", size: 12))
                                    .foregroundColor(Color("Tint Color"))
                                    .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                    .padding(.horizontal, 2.2 * .standardSpacing)
                            }
                        } .padding(.leading, .standardSpacing)
                    }
                }
            }
        }
    }
    func buttonAction(index: Int) {
    }
    var formattedDateText: Text {
        Text(" ") +
            Text(verbatim: formattedDate())
                .font(.custom("Montserrat-Regular", size: 14))
                .foregroundColor(Color("Title Text Color"))
    }
}

class Row: ObservableObject {
    @Published var isOpen = [false, false, false]
    @Published var rowNumber = 0
    // swiftlint:disable:next line_length
    @Published var exposure = [Exposure(attenuationDurations: [1], attenuationValue: 0, date: Date(), duration: 15, totalRiskScore: 1, transmissionRiskLevel: 1, attenuationDurationThresholds: [1, 2], timeDetected: Date())]
}
