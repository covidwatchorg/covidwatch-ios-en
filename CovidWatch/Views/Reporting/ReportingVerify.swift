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

                                TextField(NSLocalizedString("SELECT_DATE", comment: ""), text: $testDate)
                                    .padding(.horizontal, 2 * .standardSpacing)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Button(action: {

                                // Bypassing public health authority verification can be done:
                                // - on the app side, by configuring the app's info plist.
                                // - on the key server side, by configuring its database / authorizedapp table for this particular app.
                                let bypassPublicHealthAuthorityVerification = Bundle.main.infoDictionary?[.bypassPublicHealthAuthorityVerification] as? Bool ?? false

                                self.isSubmittingDiagnosis = true

                                let errorHandler: (Error) -> Void = { error in
                                    self.isSubmittingDiagnosis = false
                                    UIApplication.shared.topViewController?.present(
                                        error,
                                        animated: true,
                                        completion: nil
                                    )
                                }

                                if self.localStore.testResults[self.selectedTestResultIndex].verificationCode != self.verificationCode {
                                    self.localStore.testResults[self.selectedTestResultIndex].isVerified = false
                                }
                                self.localStore.testResults[self.selectedTestResultIndex].verificationCode = self.verificationCode
                                self.localStore.testResults[self.selectedTestResultIndex].isAdded = true

                                let actionAfterCodeVerification = {

                                    // To be able to calculate the hmac for the diagnosis keys, we need to request them now.
                                    ExposureManager.shared.getDiagnosisKeys { (keys, error) in
                                        if let error = error {
                                            errorHandler(error)
                                            return
                                        }

                                        guard let keys = keys, !keys.isEmpty else {
                                            errorHandler(ENError(.internal))
                                            return
                                        }

                                        // TODO: Set tranmission risk level for the diagnosis keys based on questions *before* sharing them with the key server.
                                        keys.forEach { $0.transmissionRiskLevel = 6 }

                                        let actionAfterVerificationCertificateRequest = {

                                            // Step 8 of https://developers.google.com/android/exposure-notifications/verification-system
                                            Server.shared.postDiagnosisKeys(
                                                keys,
                                                verificationPayload: self.localStore.testResults[self.selectedTestResultIndex].verificationCertificate,
                                                hmacKey: self.localStore.testResults[self.selectedTestResultIndex].hmacKey
                                            ) { error in
                                                // Step 9
                                                // Since this is the last step, ensure `isSubmittingDiagnosis` is set to false.
                                                defer {
                                                    self.isSubmittingDiagnosis = false
                                                }

                                                if let error = error {
                                                    errorHandler(error)
                                                    return
                                                }

                                                self.localStore.testResults[self.selectedTestResultIndex].isShared = true

                                                withAnimation {
                                                    self.isShowingFinish = true
                                                }
                                            }
                                        }

                                        if !bypassPublicHealthAuthorityVerification {

                                            do {
                                                let hmac = try ENVerificationUtils.calculateExposureKeyHMAC(
                                                    forTemporaryExposureKeys: keys,
                                                    secret: self.localStore.testResults[self.selectedTestResultIndex].hmacKey
                                                ).base64EncodedString()
                                                guard let longTermToken = self.localStore.testResults[self.selectedTestResultIndex].longTermToken else {
                                                    // Shouldn't get here...
                                                    self.isSubmittingDiagnosis = false
                                                    return
                                                }
                                                // Step 6 of https://developers.google.com/android/exposure-notifications/verification-system
                                                Server.shared.getVerificationCertificate(forLongTermToken: longTermToken, hmac: hmac) { result in
                                                    // Step 7
                                                    switch result {
                                                        case let .success(codableVerificationCertificateResponse):

                                                            self.localStore.testResults[self.selectedTestResultIndex].verificationCertificate = codableVerificationCertificateResponse.certificate

                                                            actionAfterVerificationCertificateRequest()

                                                        case let .failure(error):
                                                            // Something went wrong. Maybe the long-term token is not valid anymore?
                                                            self.localStore.testResults[self.selectedTestResultIndex].isVerified = false
                                                            errorHandler(error)
                                                            return
                                                    }
                                                }

                                            } catch {
                                                errorHandler(error)
                                                return
                                            }
                                        } else {
                                            actionAfterVerificationCertificateRequest()
                                        }

                                    }
                                }

                                if !self.localStore.testResults[self.selectedTestResultIndex].isVerified {

                                    if bypassPublicHealthAuthorityVerification {

                                        actionAfterCodeVerification()

                                    } else {
                                        // Step 4 of https://developers.google.com/android/exposure-notifications/verification-system
                                        Server.shared.verifyCode(self.verificationCode) { result in
                                            // Step 5
                                            switch result {
                                                case let .success(codableVerifyCodeResponse):

                                                    self.localStore.testResults[self.selectedTestResultIndex].isVerified = true
                                                    self.localStore.testResults[self.selectedTestResultIndex].longTermToken = codableVerifyCodeResponse.token
                                                    let formatter = ISO8601DateFormatter()
                                                    formatter.formatOptions = [.withFullDate]
                                                    self.localStore.testResults[self.selectedTestResultIndex].dateAdministered = formatter.date(from: codableVerifyCodeResponse.testDate) ?? Date()
                                                    self.localStore.testResults[self.selectedTestResultIndex].testType = codableVerifyCodeResponse.testType

                                                    actionAfterCodeVerification()

                                                case let .failure(error):
                                                    errorHandler(error)
                                                    return
                                            }
                                        }
                                    }

                                } else {
                                    actionAfterCodeVerification()
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
