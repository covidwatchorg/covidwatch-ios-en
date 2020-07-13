//
//  Created by Zsombor Szabo on 08/05/2020.
//  
//

import SwiftUI

struct PossibleExposures: View {

    @EnvironmentObject var userData: UserData

    @EnvironmentObject var localStore: LocalStore

    @State private var selectedExposure: Exposure?

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 0) {

                    Spacer(minLength: .headerHeight)

                    Text("POSSIBLE_EXPOSURES_TITLE")
                        .modifier(StandardTitleTextViewModifier())
                        .padding(.horizontal, 2 * .standardSpacing)

                    Spacer(minLength: 2 * .standardSpacing)

                    Toggle(isOn: self.$userData.exposureNotificationEnabled) {
                        Text("EXPOSURE_NOTIFICATIONS_TITLE")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .foregroundColor(Color.secondary)
                    }
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: .standardSpacing)

                    Text(verbatim: self.userData.exposureNotificationStatusMessage)
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundColor(Color.secondary)
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
                        if self.localStore.exposures.isEmpty {

                            HStack {
                                VStack(spacing: 0) {

                                    Text("POSSIBLE_EXPOSURES_NO_EXPOSURES_TITLE")
                                        .font(.custom("Montserrat-Bold", size: 13))
                                        .foregroundColor(Color.primary)
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .topLeading)

                                    Text("POSSIBLE_EXPOSURES_NO_EXPOSURES_MESSAGE")
                                        .font(.custom("Montserrat-Regular", size: 13))
                                        .foregroundColor(Color.secondary)
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
                            ForEach(0..<self.localStore.exposures.count) { index in

                                Group {
                                    Button(action: {
                                        if self.selectedExposure == self.localStore.exposures[index] {
                                            self.selectedExposure = nil
                                        } else {
                                            self.selectedExposure = self.localStore.exposures[index]
                                        }
                                    }) {
                                        VStack(spacing: 0) {

                                            PossibleExposureRow(
                                                exposure: self.localStore.exposures[index],
                                                isExpanded: self.localStore.exposures[index] == self.selectedExposure
                                            ).frame(minHeight: 54)
                                                .padding(.horizontal, 2 * .standardSpacing)

                                            Divider()

                                            // Is Expanded?
                                            if self.localStore.exposures[index] == self.selectedExposure {

                                                HStack {
                                                    PossibleExposureTable(exposure: self.localStore.exposures[index])
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(UIColor.systemGray6))

                                                Divider()
                                            }
                                        }
                                    }
                                    .accessibility(hint: Text("SHOWS_MORE_INFO_ACCESSIBILITY_HINT"))
                                    .frame(minHeight: 54)
                                }
                            }
                        }

                        Spacer(minLength: 2 * .standardSpacing)

                        Text("EXPOSURES_ARE_SAVED_MESSAGE")
                            .modifier(SubCallToAction())
                            .padding(.horizontal, 2 * .standardSpacing)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image("Powered By CW Grey")
                            .accessibility(label: Text("POWERED_BY_CW_IMAGE_ACCESSIBILITY_LABEL"))
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing)
                    }
                }
            }

            HeaderBar(showMenu: false, showDismissButton: true)
                .environmentObject(self.localStore)
                .environmentObject(self.userData)
        }
    }
}

struct Exposures_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposures()
    }
}
