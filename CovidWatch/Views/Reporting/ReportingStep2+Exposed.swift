//
//  Created by Zsombor Szabo on 16/08/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import SwiftUI

extension ReportingStep2 {

    var exposedStart: some View {
        Group {
            Spacer(minLength: 2 * .standardSpacing)

            Text("EXPOSED_START_DATE_QUESTION")
                .font(.custom("Montserrat-SemiBold", size: 18))
                .foregroundColor(Color("Text Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2 * .standardSpacing)

            Spacer(minLength: .standardSpacing)

            Button(action: {
                self.isShowingExposedDatePicker.toggle()
            }) {
                TextField(NSLocalizedString("SELECT_DATE", comment: ""), text: self.$exposedStartDateString)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .foregroundColor(Color("Text Color"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .opacity(dontKnowExposedDate ? 0.4 : 1.0)
                    .disabled(true)
            }
            .disabled(dontKnowExposedDate)
            .sheet(isPresented: self.$isShowingExposedDatePicker, content: {
                ZStack(alignment: .top) {
                    RKViewController(isPresented: self.$isShowingExposedDatePicker, rkManager: self.exposedStartRKManager)
                        .padding(.top, .headerHeight)

                    HeaderBar(showMenu: false, showDismissButton: true)
                        .environmentObject(self.localStore)
                }
                .onDisappear {
                    if let selectedDate = self.exposedStartRKManager.selectedDate {

                        self.exposedStartDateString = self.dateFormatter.string(from: selectedDate)
                        self.diagnosis.possibleInfectionDate = selectedDate

                        // Reset test date
                        if let testDate = self.diagnosis.testDate, testDate >= selectedDate {
                            self.testStartDateString = ""
                            self.diagnosis.testDate = nil
                            self.testStartRKManager.selectedDate = nil
                        }

                        self.configureTestStartDisabledDates()

                    } else {
                        self.exposedStartRKManager.selectedDate = self.diagnosis.possibleInfectionDate
                    }
                }
            }).modifier(TextfieldClearButton(text: self.$exposedStartDateString))

            Spacer(minLength: .standardSpacing)

            HStack(alignment: .center) {

                Button(action: {
                    withAnimation {
                        self.dontKnowExposedDate.toggle()
                        if self.dontKnowExposedDate {
                            self.exposedStartRKManager.selectedDate = nil
                            self.exposedStartDateString = ""
                            self.diagnosis.possibleInfectionDate = nil
                        }
                    }
                }) {
                    if self.dontKnowExposedDate {
                        Image("Checkbox Checked")
                    } else {
                        Image("Checkbox Unchecked")
                    }

                    Text("EXPOSED_START_DATE_UNKNOWN")
                        .foregroundColor(Color("Text Color"))
                }
            }.padding(.horizontal, 2 * .standardSpacing)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 2 * .standardSpacing)

        }
    }

}
