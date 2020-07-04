//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI
import ExposureNotification

struct ReportingVerify: View {

    @EnvironmentObject var localStore: LocalStore

    @State var isShowingFinish = false

    @State var verificationCode: String = ""

    @State var symptomsStartDate: String = ""

    @State var testDate: String = ""

    @State var isSubmittingDiagnosis = false

    let selectedTestResultIndex: Int

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    init(selectedTestResultIndex: Int = 0) {
        self.selectedTestResultIndex = selectedTestResultIndex
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }

    var body: some View {

        VStack {
            if isShowingFinish {

                ReportingFinish().transition(.opacity)

            } else {

                ZStack(alignment: .top) {

                    ScrollView(.vertical, showsIndicators: false) {

                        VStack(spacing: 0) {

                            HowItWorksTitleText(text: Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("STEP_X_OF_Y_TITLE", comment: ""), NSNumber(value: 2), NSNumber(value: 3)).uppercased()))
                                .padding(.top, .headerHeight)

                            Text("REPORTING_VERIFY_TITLE")
                                .modifier(StandardTitleTextViewModifier())
                                .padding(.horizontal, 2 * .standardSpacing)

                            Spacer(minLength: 2 * .standardSpacing)

                            Text("REPORTING_VERIFY_MESSAGE")
                                .font(.custom("Montserrat-Regular", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("Title Text Color"))
                                .padding(.horizontal, 2 * .standardSpacing)

                            Group {
                                Spacer(minLength: 2 * .standardSpacing)

                                Text("TEST_VERIFICATION_CODE_TITLE")
                                    .font(.custom("Montserrat-SemiBold", size: 18))
                                    .foregroundColor(Color("Title Text Color"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 2 * .standardSpacing)

                                Spacer(minLength: .standardSpacing)

                                TextField(NSLocalizedString("TEST_VERIFICATION_CODE_TITLE", comment: ""), text: $verificationCode)
                                    .padding(.horizontal, 2 * .standardSpacing)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Group {
                                Spacer(minLength: 2 * .standardSpacing)

                                Text("SYMPTOMS_START_DATE_QUESTION")
                                    .font(.custom("Montserrat-SemiBold", size: 18))
                                    .foregroundColor(Color("Title Text Color"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 2 * .standardSpacing)

                                Spacer(minLength: .standardSpacing)

                                TextField(NSLocalizedString("SELECT_DATE", comment: ""), text: $symptomsStartDate)
                                    .padding(.horizontal, 2 * .standardSpacing)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Group {
                                Spacer(minLength: 2 * .standardSpacing)

                                Text("TEST_DATE_QUESTION")
                                    .font(.custom("Montserrat-SemiBold", size: 18))
                                    .foregroundColor(Color("Title Text Color"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 2 * .standardSpacing)

                                Spacer(minLength: .standardSpacing)

                                TextField(NSLocalizedString("TEST_VERIFICATION_CODE_TITLE", comment: ""), text: $testDate)
                                    .padding(.horizontal, 2 * .standardSpacing)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Button(action: {

                                self.isSubmittingDiagnosis = true

                                self.localStore.testResults[self.selectedTestResultIndex].verificationCode = self.verificationCode

                                let actionAfterVerification = {

                                    ExposureManager.shared.getDiagnosisKeys { (keys, error) in
                                        if let error = error {
                                            self.isSubmittingDiagnosis = false
                                            UIApplication.shared.topViewController?.present(
                                                error,
                                                animated: true,
                                                completion: nil
                                            )
                                            return
                                        }

                                        guard let keys = keys, !keys.isEmpty else {
                                            self.isSubmittingDiagnosis = false
                                            UIApplication.shared.topViewController?.present(
                                                ENError(.internal),
                                                animated: true,
                                                completion: nil
                                            )
                                            return
                                        }

                                        // TODO: Set tranmission risk level for the diagnosis keys before sharing them with the server.
                                        keys.forEach { $0.transmissionRiskLevel = 6 }

                                        Server.shared.postDiagnosisKeys(keys) { error in
                                            defer {
                                                self.isSubmittingDiagnosis = false
                                            }

                                            if let error = error {
                                                UIApplication.shared.topViewController?.present(
                                                    error,
                                                    animated: true,
                                                    completion: nil
                                                )
                                                return
                                            }

                                            withAnimation {
                                                self.isShowingFinish = true
                                            }
                                        }
                                    }
                                }

                                if !self.localStore.testResults[self.selectedTestResultIndex].isVerified {

                                    let bypassVerification = Bundle.main.infoDictionary?[.bypassPublicHealthAuthorityVerification] as? Bool ?? false

                                    if bypassVerification {

                                        actionAfterVerification()

                                    } else {
                                        Server.shared.verifyUniqueTestIdentifier(self.verificationCode) { result in
                                            DispatchQueue.main.async {
                                                switch result {
                                                    case let .success(longTermToken):
                                                        self.localStore.testResults[self.selectedTestResultIndex].longTermToken = longTermToken
                                                        self.localStore.testResults[self.selectedTestResultIndex].isVerified = true
                                                        actionAfterVerification()
                                                    case let .failure(error):
                                                        self.isSubmittingDiagnosis = false
                                                        UIApplication.shared.topViewController?.present(
                                                            error,
                                                            animated: true,
                                                            completion: nil
                                                    )
                                                }
                                            }
                                        }
                                    }

                                } else {
                                    actionAfterVerification()
                                }

                            }) {
                                Group {
                                    if !isSubmittingDiagnosis {
                                        Text("REPORTING_VERIFY_NOTIFY_OTHERS")
                                    } else {
                                        ActivityIndicator(isAnimating: $isSubmittingDiagnosis) {
                                            $0.color = .white
                                        }
                                    }
                                }.modifier(SmallCallToAction())
                            }
                            .disabled(isSubmittingDiagnosis)
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing)

                            Image("Doctors Security")
                                .accessibility(hidden: true)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                        }
                    }

                    HeaderBar(showMenu: false, showDismissButton: true)
                }
                .transition(.opacity)
            }
        }
    }
}

struct ReportingCallCode_Previews: PreviewProvider {
    static var previews: some View {
        ReportingVerify()
    }
}
