//
//  Created by Zsombor Szabo on 16/08/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import SwiftUI

extension ReportingStep2 {

    var symptomsStart: some View {
        Group {
            Spacer(minLength: 2 * .standardSpacing)

            Text("SYMPTOMS_START_DATE_QUESTION")
                .font(.custom("Montserrat-SemiBold", size: 18))
                .foregroundColor(Color("Text Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2 * .standardSpacing)

            Spacer(minLength: .standardSpacing)

            Button(action: {
                self.isShowingSymptonOnSetDatePicker.toggle()
            }) {
                TextField(NSLocalizedString("SELECT_DATE", comment: ""), text: self.$symptomsStartDateString)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .foregroundColor(Color("Text Color"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .opacity(isAsymptomatic ? 0.4 : 1.0)
                    .disabled(true)
            }
            .disabled(isAsymptomatic)
            .sheet(isPresented: self.$isShowingSymptonOnSetDatePicker, content: {
                ZStack(alignment: .top) {
                    RKViewController(isPresented: self.$isShowingSymptonOnSetDatePicker, rkManager: self.symptomsStartRKManager)
                        .padding(.top, .headerHeight)

                    HeaderBar(showMenu: false, showDismissButton: true)
                        .environmentObject(self.localStore)
                }
                .onDisappear {
                    withAnimation {
                        if let selectedDate = self.symptomsStartRKManager.selectedDate {

                            self.symptomsStartDateString = self.dateFormatter.string(from: selectedDate)
                            self.diagnosis.symptomsStartDate = selectedDate

                        } else {
                            self.symptomsStartRKManager.selectedDate = self.diagnosis.symptomsStartDate
                        }
                    }
                }
            }).modifier(TextfieldClearButton(text: self.$symptomsStartDateString))

            Spacer(minLength: .standardSpacing)

            HStack(alignment: .center) {

                Button(action: {
                    withAnimation {
                        self.isAsymptomatic.toggle()

                        if self.isAsymptomatic {

                            self.symptomsStartRKManager.selectedDate = nil
                            self.symptomsStartDateString = ""
                            self.diagnosis.symptomsStartDate = nil
                        }

                        self.exposedStartRKManager.selectedDate = nil
                        self.exposedStartDateString = ""
                        self.diagnosis.possibleInfectionDate = nil

                        self.testStartRKManager.selectedDate = nil
                        self.testStartDateString = ""
                        self.diagnosis.testDate = nil
                    }
                }) {
                    if self.isAsymptomatic {
                        Image("Checkbox Checked")
                    } else {
                        Image("Checkbox Unchecked")
                    }

                    Text("SYMPTOMS_START_DATE_ASYMPTOMATIC")
                        .foregroundColor(Color("Text Color"))
                }
            }.padding(.horizontal, 2 * .standardSpacing)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 2 * .standardSpacing)

        }
    }
}
