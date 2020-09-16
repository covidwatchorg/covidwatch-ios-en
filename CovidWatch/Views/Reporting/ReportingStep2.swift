//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI
import ExposureNotification

struct ReportingStep2: View {

    @EnvironmentObject var localStore: LocalStore

    @State var isShowingWhereIsMyCode: Bool = false

    @State var verificationCode: String = ""

    @State var hasVerificationCode = false

    @State var symptomsStartDateString: String = ""

    @State var isSubmittingDiagnosis = false

    @State var isShowingNextStep = false

    @State var isShowingSymptonOnSetDatePicker = false

    @State var isShowingExposedDatePicker = false

    @State var exposedStartDateString: String = ""

    @State var isShowingTestDatePicker = false

    @State var testStartDateString: String = ""

    @State var diagnosis = Diagnosis(
        id: UUID(),
        isSubmitted: false,
        testType: .testTypeConfirmed
    )

    static func createRKManager() -> RKManager {
        let manager = RKManager(
            calendar: .current,
            minimumDate: Date().addingTimeInterval(-60*60*24*14),
            maximumDate: Date().addingTimeInterval(60*60*24*30),
            mode: 0
        )
        manager.colors.selectedBackColor = Color("Tint Color")
        manager.disabledDates = (1...30).map({ Date().addingTimeInterval(60*60*24*Double($0)) })
        return manager
    }

    var symptomsStartRKManager: RKManager = createRKManager()

    var exposedStartRKManager: RKManager = createRKManager()

    var testStartRKManager: RKManager = createRKManager()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    @State var isAsymptomatic = false

    @State var dontKnowExposedDate = false

    @State var dontKnowTestDate = false

    init() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }

    var body: some View {

        ZStack(alignment: .top) {

            if !isShowingNextStep {
                reportingStep2.transition(.slide)
            } else {
                ReportingStep3().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }

            HeaderBar(showMenu: false, showDismissButton: true)
        }
    }

    var reportingStep2: some View {

        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {

                Spacer(minLength: .headerHeight + .standardSpacing)

                Text("REPORTING_VERIFY_TITLE")
                    .modifier(StandardTitleTextViewModifier())
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer(minLength: 2 * .standardSpacing)

                Group {
                    Spacer(minLength: 2 * .standardSpacing)

                    Button(action: {
                        self.isShowingWhereIsMyCode.toggle()
                    }) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("VERIFICATION_CODE_QUESTION")
                                .font(.custom("Montserrat-SemiBold", size: 18))
                                .foregroundColor(Color("Text Color"))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Image(systemName: "info.circle.fill")
                        }
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .sheet(isPresented: $isShowingWhereIsMyCode) {
                        WhereIsMyCode()
                            .environmentObject(self.localStore)
                    }

                    Spacer(minLength: .standardSpacing)

                    TextField(NSLocalizedString("VERIFICATION_CODE_TITLE", comment: ""), text: self.$verificationCode)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .foregroundColor(Color("Text Color"))
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onReceive([self.verificationCode].publisher.first()) { _ in
                            withAnimation {
                                self.hasVerificationCode = !self.verificationCode.isEmpty
                            }
                    }

                    Spacer().frame(height: 2 * .standardSpacing)
                }

                if self.hasVerificationCode {
                    Divider()
                        .padding(.horizontal, .standardSpacing)

                    self.symptomsStart

                    if self.isAsymptomatic {
                        Divider()
                            .padding(.horizontal, .standardSpacing)

                        self.exposedStart

                        Divider()
                            .padding(.horizontal, .standardSpacing)

                        self.testStart
                    }

                    if (!self.symptomsStartDateString.isEmpty) || (self.isAsymptomatic && !self.testStartDateString.isEmpty) {
                        Button(action: {

                            let actionsAfterExposureNotificationsEnabled = {

                                // Bypassing public health authority verification can be done:
                                // - on the app side, by configuring the app's info plist.
                                // - on the key server side, by configuring its database / authorizedapp table for this particular app.
                                let bypassPublicHealthAuthorityVerification = Bundle.main.infoDictionary?[.bypassPublicHealthAuthorityVerification] as? Bool ?? false

                                self.isSubmittingDiagnosis = true

                                let errorHandler: (Error) -> Void = { error in

                                    self.isSubmittingDiagnosis = false

                                    if case let GoogleExposureNotificationsDiagnosisVerificationServer.ServerError.serverSideError(errorMessage) = error, errorMessage == "internal server error" {

                                        UIApplication.shared.topViewController?.present(
                                            title: NSLocalizedString("VERIFICATION_INVALID_SERVER_ERROR_TITLE", comment: ""),
                                            message: NSLocalizedString("VERIFICATION_INVALID_SERVER_ERROR_MESSAGE", comment: ""),
                                            animated: true,
                                            completion: nil
                                        )

                                        return

                                    } else if case let GoogleExposureNotificationsDiagnosisVerificationServer.ServerError.serverSideError(errorMessage) = error, errorMessage == "verification code used" {

                                        let contactAction = UIAlertAction(title: NSLocalizedString("CONTACT", comment: ""), style: .cancel) { (_) in
                                            self.isShowingWhereIsMyCode.toggle()
                                            _ = self.sheet(isPresented: self.$isShowingWhereIsMyCode) {
                                                WhereIsMyCode()
                                                    .environmentObject(self.localStore)
                                            }
                                        }

                                        UIApplication.shared.topViewController?.present(
                                            title: NSLocalizedString("VERIFICATION_INVALID_SERVER_ERROR_TITLE", comment: ""),
                                            message: NSLocalizedString("VERIFICATION_CODE_USED_ERROR_MESSAGE", comment: ""),
                                            recoveryAction: contactAction,
                                            animated: true,
                                            completion: nil
                                        )

                                        return

                                    } else if case let GoogleExposureNotificationsDiagnosisVerificationServer.ServerError.serverSideError(errorMessage) = error, errorMessage == "verification code expired" {

                                        let contactAction = UIAlertAction(title: NSLocalizedString("CONTACT", comment: ""), style: .cancel) { (_) in
                                            self.isShowingWhereIsMyCode.toggle()
                                            _ = self.sheet(isPresented: self.$isShowingWhereIsMyCode) {
                                                WhereIsMyCode()
                                                    .environmentObject(self.localStore)
                                            }
                                        }

                                        UIApplication.shared.topViewController?.present(
                                            title: NSLocalizedString("VERIFICATION_INVALID_SERVER_ERROR_TITLE", comment: ""),
                                            message: NSLocalizedString("VERIFICATION_CODE_EXPIRED_ERROR_MESSAGE", comment: ""),
                                            recoveryAction: contactAction,
                                            animated: true,
                                            completion: nil
                                        )

                                        return
                                    }

                                    UIApplication.shared.topViewController?.present(
                                        error,
                                        animated: true,
                                        completion: nil
                                    )
                                }

                                let emptyKeyListHandler: () -> Void = {
                                    self.isSubmittingDiagnosis = false
                                    self.diagnosis.isSubmitted = true
                                    self.localStore.diagnoses.insert(self.diagnosis, at: 0)
                                    withAnimation {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        self.isShowingNextStep = true
                                    }
                                }

                                if self.diagnosis.verificationCode != self.verificationCode {
                                    self.diagnosis.isVerified = false
                                }
                                self.diagnosis.verificationCode = self.verificationCode
                                self.diagnosis.isAdded = true

                                let actionAfterCodeVerification = {

                                    // To be able to calculate the hmac for the diagnosis keys, we need to request them now.
                                    ExposureManager.shared.getDiagnosisKeys { (keys, error) in
                                        if let error = error {
                                            errorHandler(error)
                                            return
                                        }

                                        guard var keys = keys, !keys.isEmpty else {
                                            emptyKeyListHandler()
                                            return
                                        }

                                        // Before uploading the diagnosis keys to the key server, set their:
                                        // - Tranmission Risk Level (v1.0 and above)
                                        // - Days Since Onset (v1.5 and above)
                                        // - Report Type (v1.5 and above)

                                        // Set tranmission risk level based on symptoms start date
                                        keys.forEach({ $0.transmissionRiskLevel = 6 })

                                        if let riskModel = ExposureManager.shared.riskModel {

                                            keys.forEach {
                                                $0.transmissionRiskLevel = riskModel.computeTransmissionRiskLevel(
                                                    forTemporaryExposureKey: $0,
                                                    symptomsStartDate: self.diagnosis.symptomsStartDate,
                                                    testDate: self.diagnosis.testDate,
                                                    possibleInfectionDate: self.diagnosis.possibleInfectionDate
                                                )
                                            }

                                            // Filter out keys if needed, to optimize server storage.
                                            if !self.diagnosis.shareZeroTranmissionRiskLevelDiagnosisKeys {
                                                keys = keys.filter({ $0.transmissionRiskLevel != 0 })
                                            }
                                        }

                                        let actionAfterVerificationCertificateRequest = {

                                            // Step 8 of https://developers.google.com/android/exposure-notifications/verification-system
                                            Server.shared.postDiagnosisKeys(
                                                keys,
                                                verificationPayload: self.diagnosis.verificationCertificate,
                                                hmacKey: self.diagnosis.hmacKey) { (error) in

                                                    // Step 9
                                                    // Since this is the last step, ensure `isSubmittingDiagnosis` is set to false.
                                                    defer {
                                                        self.isSubmittingDiagnosis = false
                                                    }

                                                    if let error = error {
                                                        errorHandler(error)
                                                    }

                                                    self.diagnosis.isSubmitted = true
                                                    self.localStore.diagnoses.insert(self.diagnosis, at: 0)

                                                    withAnimation {
                                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                        self.isShowingNextStep = true
                                                    }
                                            }
                                        }

                                        if !bypassPublicHealthAuthorityVerification {

                                            do {
                                                let hmac = try ENVerificationUtils.calculateExposureKeyHMAC(
                                                    forTemporaryExposureKeys: keys,
                                                    secret: self.diagnosis.hmacKey
                                                ).base64EncodedString()
                                                guard let longTermToken = self.diagnosis.longTermToken else {
                                                    // Shouldn't get here...
                                                    self.isSubmittingDiagnosis = false
                                                    return
                                                }
                                                // Step 6 of https://developers.google.com/android/exposure-notifications/verification-system
                                                Server.shared.getVerificationCertificate(forLongTermToken: longTermToken, hmac: hmac) { result in
                                                    // Step 7
                                                    switch result {
                                                        case let .success(codableVerificationCertificateResponse):

                                                            self.diagnosis.verificationCertificate = codableVerificationCertificateResponse.certificate

                                                            actionAfterVerificationCertificateRequest()

                                                        case let .failure(error):
                                                            // Something went wrong. Maybe the long-term token is not valid anymore?
                                                            self.diagnosis.isVerified = false
                                                            errorHandler(error)
                                                            return
                                                    }
                                                }

                                            } catch {
                                                if let error = error as? ENVerificationUtils.ENVerificationUtilsError,
                                                    error == .emptyListOfKeys {

                                                    emptyKeyListHandler()

                                                    return
                                                }

                                                errorHandler(error)
                                                return
                                            }
                                        } else {
                                            actionAfterVerificationCertificateRequest()
                                        }

                                    }
                                }

                                if !self.diagnosis.isVerified {

                                    if bypassPublicHealthAuthorityVerification {

                                        actionAfterCodeVerification()

                                    } else {
                                        // Step 4 of https://developers.google.com/android/exposure-notifications/verification-system
                                        Server.shared.verifyCode(self.verificationCode) { result in
                                            // Step 5
                                            switch result {
                                                case let .success(codableVerifyCodeResponse):

                                                    self.diagnosis.isVerified = true
                                                    self.diagnosis.longTermToken = codableVerifyCodeResponse.token
                                                    let formatter = ISO8601DateFormatter()
                                                    formatter.formatOptions = [.withFullDate]
                                                    if let date = codableVerifyCodeResponse.symptomDate, !date.isEmpty {
                                                        self.diagnosis.symptomsStartDate = formatter.date(from: date)
                                                    }
                                                    self.diagnosis.testType = codableVerifyCodeResponse.testType

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
                            }

                            if self.localStore.exposureNotificationStatus != .active {

                                let alertController = UIAlertController(
                                    title: NSLocalizedString("ENABLE_EXPOSURE_NOTIFICATIONS_SHARE_DIAGNOSIS_TITLE", comment: ""),
                                    message: NSLocalizedString("ENABLE_EXPOSURE_NOTIFICATIONS_SHARE_DIAGNOSIS_MESSAGE", comment: ""),
                                    preferredStyle: .alert
                                )
                                alertController.addAction(UIAlertAction(
                                    title: NSLocalizedString("CANCEL", comment: ""),
                                    style: .cancel,
                                    handler: nil)
                                )
                                alertController.addAction(UIAlertAction(
                                    title: NSLocalizedString("ENABLE", comment: ""),
                                    style: .default,
                                    handler: { (_) in
                                        ExposureManager.shared.manager.setExposureNotificationEnabled(true) { (error) in

                                            if let error = error {
                                                ApplicationController.shared.handleExposureNotificationEnabled(error: error)
                                                return
                                            }

                                            actionsAfterExposureNotificationsEnabled()
                                        }
                                    })
                                )
                                UIApplication.shared.topViewController?.present(alertController, animated: true)

                            } else {
                                actionsAfterExposureNotificationsEnabled()
                            }

                        }) {
                            Group {
                                if !self.isSubmittingDiagnosis {
                                    Text("REPORTING_VERIFY_NOTIFY_OTHERS")
                                } else {
                                    ActivityIndicator(isAnimating: self.$isSubmittingDiagnosis) {
                                        $0.color = .white
                                    }
                                }
                            }.modifier(SmallCallToAction())
                        }
                        .disabled(self.isSubmittingDiagnosis)
                        .padding(.top, 3 * .standardSpacing)
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.bottom, .standardSpacing)
                    }

                }

                Image("Notify Others Footer")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    .accessibility(hidden: true)
                    .transition(.slide)
            }
        }

    }

}

struct ReportingCallCode_Previews: PreviewProvider {
    static var previews: some View {
        ReportingStep2()
    }
}
