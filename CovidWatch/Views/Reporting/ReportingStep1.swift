//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI
import ExposureNotification

struct ReportingStep1: View {

    @EnvironmentObject var localStore: LocalStore

    @EnvironmentObject var userData: UserData

    @State var isShowingNextStep = false

    @State var selectedDiagnosisIndex = 0

    var body: some View {

        ZStack(alignment: .top) {

            if !isShowingNextStep {
                reportingStep1.transition(.slide)
            } else {
                ReportingStep2().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }

            HeaderBar(showMenu: false, showDismissButton: true)
        }
    }

    var reportingStep1: some View {
        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {

                HowItWorksTitleText(text: Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("STEP_X_OF_Y_TITLE", comment: ""), NSNumber(value: 1), NSNumber(value: 3)).uppercased()))
                    .padding(.top, .headerHeight)

                Text("NOTIFY_OTHERS_TITLE")
                    .modifier(StandardTitleTextViewModifier())
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer(minLength: 2 * .standardSpacing)

                Text("NOTIFY_OTHERS_CALL_TO_ACTION_LONG_MESSAGE")
                    .font(.custom("Montserrat-Regular", size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.secondary)
                    .padding(.horizontal, 2 * .standardSpacing)

                Button(action: {

                    #if DEBUG_CALIBRATION

                    ApplicationController.shared.handleTapCalibrationShareAPositiveDiagnosisButton()

                    #else

                    let diagnosis = Diagnosis(
                        id: UUID(),
                        isAdded: false,
                        testDate: Date(),
                        isShared: false,
                        isVerified: false,
                        testType: .testTypeConfirmed
                    )
                    self.localStore.diagnoses.insert(diagnosis, at: 0)
                    self.selectedDiagnosisIndex = 0

                    withAnimation {
                        self.isShowingNextStep = true
                    }

                    #endif

                }) {

                    Text("SHARE_A_POSITIVE_DIAGNOSIS").modifier(SmallCallToAction())

                }
                .padding(.top, 2 * .standardSpacing)
                .padding(.horizontal, 2 * .standardSpacing)
                .padding(.bottom, .standardSpacing)

                Image("Notify Others Footer")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    .accessibility(hidden: true)

            }
        }
    }
}

struct Reporting_Previews: PreviewProvider {
    static var previews: some View {
        ReportingStep1()
    }
}
