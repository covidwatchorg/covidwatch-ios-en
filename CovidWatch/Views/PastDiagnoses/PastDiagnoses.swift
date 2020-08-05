//
//  Created by Zsombor Szabo on 17/07/2020.
//  
//

import SwiftUI

struct PastDiagnoses: View {

    @EnvironmentObject var localStore: LocalStore

    @State private var selectedDiagnosis: Diagnosis?

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Spacer(minLength: .headerHeight + .standardSpacing)

                    Text("PAST_DIAGNOSES_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    ForEach(self.localStore.diagnoses, id: \.id) { diagnosis in

                        VStack(spacing: 0) {
                            Button(action: {
                                if self.selectedDiagnosis == diagnosis {
                                    self.selectedDiagnosis = nil
                                } else {
                                    self.selectedDiagnosis = diagnosis
                                }
                            }) {
                                VStack(spacing: 0) {

                                    Divider()

                                    PastDiagnosisRow(
                                        diagnosis: diagnosis,
                                        isExpanded: diagnosis == self.selectedDiagnosis
                                    ).frame(minHeight: 54)
                                        .padding(.horizontal, 2 * .standardSpacing)

                                    // Is Expanded?
                                    if diagnosis == self.selectedDiagnosis {
                                        Divider()
                                    }

                                }
                            }
                            .accessibility(hint: Text("SHOWS_MORE_INFO_ACCESSIBILITY_HINT"))
                            .frame(minHeight: 54)

                            if diagnosis == self.selectedDiagnosis {

                                ZStack(alignment: .bottom) {

                                    ZStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 0) {

                                            VStack(alignment: .leading, spacing: 5) {
                                                HStack {
                                                    Text("SYMPTOMS_START_DATE")
                                                        .font(.custom("Montserrat-Semibold", size: 13))

                                                    Text(verbatim: self.selectedDiagnosis?.symptomsStartDate == nil ? NSLocalizedString("N/A", comment: "") : DateFormatter.localizedString(from: self.selectedDiagnosis!.symptomsStartDate!, dateStyle: .medium, timeStyle: .none))
                                                        .font(.custom("Montserrat-Regular", size: 13))
                                                }

                                                HStack {
                                                    Text("POSSIBLE_INFECTION_DATE")
                                                        .font(.custom("Montserrat-Semibold", size: 13))

                                                    Text(verbatim: self.selectedDiagnosis?.possibleInfectionDate == nil ? NSLocalizedString("N/A", comment: "") : DateFormatter.localizedString(from: self.selectedDiagnosis!.possibleInfectionDate!, dateStyle: .medium, timeStyle: .none))
                                                        .font(.custom("Montserrat-Regular", size: 13))
                                                }

                                                HStack {
                                                    Text("TEST_DATE")
                                                        .font(.custom("Montserrat-Semibold", size: 13))

                                                    Text(verbatim: self.selectedDiagnosis?.testDate == nil ? NSLocalizedString("N/A", comment: "") : DateFormatter.localizedString(from: self.selectedDiagnosis!.testDate!, dateStyle: .medium, timeStyle: .none))
                                                        .font(.custom("Montserrat-Regular", size: 13))
                                                }
                                            }
                                            .accessibilityElement(children: .combine)

                                            Spacer().frame(height: 2 * .standardSpacing)

                                            Button(action: {

                                                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                                actionSheet.addAction(UIAlertAction(title: NSLocalizedString("DELETE_DIAGNOSIS", comment: ""), style: .destructive, handler: { _ in

                                                    self.selectedDiagnosis = nil
                                                    self.localStore.diagnoses.removeAll(where: ({ $0 == diagnosis }))

                                                }))
                                                actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))

                                                UIApplication.shared.topViewController?.present(actionSheet, animated: true)

                                            }) {
                                                Text("DELETE_DIAGNOSIS")
                                                    .font(.custom("Montserrat-Semibold", size: 13))
                                            }

                                        }
                                        .padding(.vertical, 2 * .standardSpacing)
                                        .padding(.horizontal, 4 * .standardSpacing)
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
                        }
                    }

                    Divider()
                }
            }

            HeaderBar(showMenu: false, showDismissButton: true)
                .environmentObject(self.localStore)
        }
    }
}

struct PastDiagnoses_Previews: PreviewProvider {
    static var previews: some View {
        PastDiagnoses()
    }
}
