//
//  Created by Zsombor Szabo on 12/07/2020.
//  
//

import SwiftUI

struct NextSteps: View {

    @EnvironmentObject var userData: UserData

    @EnvironmentObject var localStore: LocalStore

    var body: some View {
        VStack(spacing: 0) {
            Text("HOME_NEXT_STEPS_MESSAGE")
                .font(.custom("Montserrat-Semibold", size: 14))
                .foregroundColor(Color.primary)
                .padding(.horizontal, 2 * .standardSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: .standardSpacing)

            ForEach(self.localStore.riskLevelNextSteps, id: \.self) { nextStep in

                VStack(spacing: 0) {

                    Spacer().frame(height: 3)

                    Button(action: {

                        switch nextStep.type {
                            case .share:
                                if let url = nextStep.url {
                                    guard let url = URL(string: url) else {
                                        UIApplication.shared.topViewController?.present(
                                            URLError(.badURL),
                                            animated: true
                                        )
                                        return
                                    }
                                    ApplicationController.shared.handleTapShareApp(url: url)
                            }

                            default:
                                if let url = nextStep.url {
                                    guard let url = URL(string: url) else {
                                        UIApplication.shared.topViewController?.present(
                                            URLError(.badURL),
                                            animated: true
                                        )
                                        return
                                    }
                                    guard UIApplication.shared.canOpenURL(url) else {
                                        UIApplication.shared.topViewController?.present(
                                            URLError(.unsupportedURL),
                                            animated: true
                                        )
                                        return
                                    }
                                    UIApplication.shared.open(url, completionHandler: nil)
                            }
                        }

                    }) {
                        HStack(alignment: .firstTextBaseline, spacing: .standardSpacing) {

                            Text(verbatim: nextStep.description)
                                .foregroundColor(Color.secondary)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, maxHeight: .infinity, alignment: .leading)
                                .font(.custom("Montserrat-Regular", size: 14))

                            Image(systemName: nextStep.type.systemImageName)
                                .foregroundColor(Color("Tint Color"))
                        }
                        .padding(.standardSpacing)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, maxHeight: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemBackground))
                    }

                    Spacer().frame(height: 3)
                }
                .padding(.horizontal, .standardSpacing)
            }
        }
    }
}

struct NextSteps_Previews: PreviewProvider {
    static var previews: some View {
        NextSteps()
    }
}
