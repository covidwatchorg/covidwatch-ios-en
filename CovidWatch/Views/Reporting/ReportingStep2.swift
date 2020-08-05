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

    @State var symptomsStartDateString: String = ""

    @State var isSubmittingDiagnosis = false

    @State var isShowingNextStep = false

    @State var isShowingSymptonOnSetDatePicker = false

    @State var isShowingExposedDatePicker = false

    @State var exposedStartDateString: String = ""

    @State var isShowingTestDatePicker = false

    @State var testStartDateString: String = ""

    var rkManager: RKManager = {
        let manager = RKManager(calendar: Calendar.current, minimumDate: Date()-14*24*60*60, maximumDate: Date(), mode: 0)
        manager.colors.selectedBackColor = Color("Tint Color")
        return manager
    }()

    let selectedDiagnosisIndex: Int

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    @State var isAsymptomatic = false

    @State var dontKnowExposedDate = false

    @State var dontKnowTestDate = false

    init(selectedDiagnosisIndex: Int = 0) {
        self.selectedDiagnosisIndex = selectedDiagnosisIndex
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

                    Spacer().frame(height: 2 * .standardSpacing)
                }

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

                if self.isAsymptomatic || !self.symptomsStartDateString.isEmpty {
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

                        let emptyKeyListHandler: () -> Void = {
                            self.isSubmittingDiagnosis = false
                            self.localStore.diagnoses[self.selectedDiagnosisIndex].isSubmitted = true
                            withAnimation {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                self.isShowingNextStep = true
                            }
                        }

                        if self.localStore.diagnoses[self.selectedDiagnosisIndex].verificationCode != self.verificationCode {
                            self.localStore.diagnoses[self.selectedDiagnosisIndex].isVerified = false
                        }
                        self.localStore.diagnoses[self.selectedDiagnosisIndex].verificationCode = self.verificationCode
                        self.localStore.diagnoses[self.selectedDiagnosisIndex].isAdded = true

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
                                            symptomsStartDate: self.localStore.diagnoses[self.selectedDiagnosisIndex].symptomsStartDate,
                                            testDate: self.localStore.diagnoses[self.selectedDiagnosisIndex].testDate,
                                            possibleInfectionDate: self.localStore.diagnoses[self.selectedDiagnosisIndex].possibleInfectionDate
                                        )
                                    }

                                    // Filter out keys if needed, to optimize server storage.
                                    if !self.localStore.diagnoses[self.selectedDiagnosisIndex].shareZeroTranmissionRiskLevelDiagnosisKeys {
                                        keys = keys.filter({ $0.transmissionRiskLevel != 0 })
                                    }
                                }

                                let actionAfterVerificationCertificateRequest = {

                                    // Step 8 of https://developers.google.com/android/exposure-notifications/verification-system
                                    Server.shared.postDiagnosisKeys(
                                        keys,
                                        verificationPayload: self.localStore.diagnoses[self.selectedDiagnosisIndex].verificationCertificate,
                                        hmacKey: self.localStore.diagnoses[self.selectedDiagnosisIndex].hmacKey
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

                                        self.localStore.diagnoses[self.selectedDiagnosisIndex].isSubmitted = true

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
                                            secret: self.localStore.diagnoses[self.selectedDiagnosisIndex].hmacKey
                                        ).base64EncodedString()
                                        guard let longTermToken = self.localStore.diagnoses[self.selectedDiagnosisIndex].longTermToken else {
                                            // Shouldn't get here...
                                            self.isSubmittingDiagnosis = false
                                            return
                                        }
                                        // Step 6 of https://developers.google.com/android/exposure-notifications/verification-system
                                        Server.shared.getVerificationCertificate(forLongTermToken: longTermToken, hmac: hmac) { result in
                                            // Step 7
                                            switch result {
                                                case let .success(codableVerificationCertificateResponse):

                                                    self.localStore.diagnoses[self.selectedDiagnosisIndex].verificationCertificate = codableVerificationCertificateResponse.certificate

                                                    actionAfterVerificationCertificateRequest()

                                                case let .failure(error):
                                                    // Something went wrong. Maybe the long-term token is not valid anymore?
                                                    self.localStore.diagnoses[self.selectedDiagnosisIndex].isVerified = false
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

                        if !self.localStore.diagnoses[self.selectedDiagnosisIndex].isVerified {

                            if bypassPublicHealthAuthorityVerification {

                                actionAfterCodeVerification()

                            } else {
                                // Step 4 of https://developers.google.com/android/exposure-notifications/verification-system
                                Server.shared.verifyCode(self.verificationCode) { result in
                                    // Step 5
                                    switch result {
                                        case let .success(codableVerifyCodeResponse):

                                            self.localStore.diagnoses[self.selectedDiagnosisIndex].isVerified = true
                                            self.localStore.diagnoses[self.selectedDiagnosisIndex].longTermToken = codableVerifyCodeResponse.token
                                            let formatter = ISO8601DateFormatter()
                                            formatter.formatOptions = [.withFullDate]
                                            if let date = codableVerifyCodeResponse.symptomDate {
                                                self.localStore.diagnoses[self.selectedDiagnosisIndex].symptomsStartDate = formatter.date(from: date)
                                            }
                                            self.localStore.diagnoses[self.selectedDiagnosisIndex].testType = codableVerifyCodeResponse.testType

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

                Image("Notify Others Footer")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    .accessibility(hidden: true)
                    .transition(.slide)
            }
        }

    }

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
                    .opacity(isAsymptomatic ? 0.5 : 1.0)
                    .disabled(true)
            }
            .disabled(isAsymptomatic)
            .sheet(isPresented: self.$isShowingSymptonOnSetDatePicker, content: {
                ZStack(alignment: .top) {
                    RKViewController(isPresented: self.$isShowingSymptonOnSetDatePicker, rkManager: self.rkManager)
                        .padding(.top, .headerHeight)

                    HeaderBar(showMenu: false, showDismissButton: true)
                        .environmentObject(self.localStore)
                }
                .onDisappear {
                    withAnimation {
                        self.symptomsStartDateString = self.rkManager.selectedDate == nil ? "" : self.dateFormatter.string(from: self.rkManager.selectedDate)
                        self.localStore.diagnoses[self.selectedDiagnosisIndex].symptomsStartDate = self.rkManager.selectedDate
                    }
                }
            })

            Spacer(minLength: .standardSpacing)

            HStack(alignment: .center) {

                Button(action: {
                    withAnimation {
                        self.isAsymptomatic.toggle()
                        if self.isAsymptomatic {
                            self.rkManager.selectedDate = nil
                            self.symptomsStartDateString = ""
                            self.localStore.diagnoses[self.selectedDiagnosisIndex].symptomsStartDate = nil
                        }
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
                    .opacity(dontKnowExposedDate ? 0.5 : 1.0)
                    .disabled(true)
            }
            .disabled(dontKnowExposedDate)
            .sheet(isPresented: self.$isShowingExposedDatePicker, content: {
                ZStack(alignment: .top) {
                    RKViewController(isPresented: self.$isShowingExposedDatePicker, rkManager: self.rkManager)
                        .padding(.top, .headerHeight)

                    HeaderBar(showMenu: false, showDismissButton: true)
                        .environmentObject(self.localStore)
                }
                .onDisappear {
                    self.exposedStartDateString = self.rkManager.selectedDate == nil ? "" : self.dateFormatter.string(from: self.rkManager.selectedDate)
                    self.localStore.diagnoses[self.selectedDiagnosisIndex].possibleInfectionDate = self.rkManager.selectedDate
                }
            })

            Spacer(minLength: .standardSpacing)

            HStack(alignment: .center) {

                Button(action: {
                    withAnimation {
                        self.dontKnowExposedDate.toggle()
                        if self.dontKnowExposedDate {
                            self.rkManager.selectedDate = nil
                            self.exposedStartDateString = ""
                            self.localStore.diagnoses[self.selectedDiagnosisIndex].possibleInfectionDate = nil
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

    var testStart: some View {
        Group {
            Spacer(minLength: 2 * .standardSpacing)

            Text("TEST_START_DATE_QUESTION")
                .font(.custom("Montserrat-SemiBold", size: 18))
                .foregroundColor(Color("Text Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 2 * .standardSpacing)

            Spacer(minLength: .standardSpacing)

            Button(action: {
                self.isShowingTestDatePicker.toggle()
            }) {
                TextField(NSLocalizedString("SELECT_DATE", comment: ""), text: self.$testStartDateString)
                    .padding(.horizontal, 2 * .standardSpacing)
                    .foregroundColor(Color("Text Color"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .opacity(dontKnowTestDate ? 0.5 : 1.0)
                    .disabled(true)
            }
            .disabled(dontKnowTestDate)
            .sheet(isPresented: self.$isShowingTestDatePicker, content: {
                ZStack(alignment: .top) {
                    RKViewController(isPresented: self.$isShowingTestDatePicker, rkManager: self.rkManager)
                        .padding(.top, .headerHeight)

                    HeaderBar(showMenu: false, showDismissButton: true)
                        .environmentObject(self.localStore)
                }
                .onDisappear {
                    self.testStartDateString = self.rkManager.selectedDate == nil ? "" : self.dateFormatter.string(from: self.rkManager.selectedDate)
                    self.localStore.diagnoses[self.selectedDiagnosisIndex].testDate = self.rkManager.selectedDate
                }
            })

            Spacer(minLength: .standardSpacing)

            HStack(alignment: .center) {

                Button(action: {
                    withAnimation {
                        self.dontKnowTestDate.toggle()
                        if self.dontKnowTestDate {
                            self.rkManager.selectedDate = nil
                            self.testStartDateString = ""
                            self.localStore.diagnoses[self.selectedDiagnosisIndex].testDate = nil
                        }
                    }
                }) {
                    if self.dontKnowTestDate {
                        Image("Checkbox Checked")
                    } else {
                        Image("Checkbox Unchecked")
                    }

                    Text("TEST_START_DATE_UNKNOWN")
                        .foregroundColor(Color("Text Color"))
                }
            }.padding(.horizontal, 2 * .standardSpacing)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 2 * .standardSpacing)

        }
    }
}

struct ReportingCallCode_Previews: PreviewProvider {
    static var previews: some View {
        ReportingStep2()
    }
}
