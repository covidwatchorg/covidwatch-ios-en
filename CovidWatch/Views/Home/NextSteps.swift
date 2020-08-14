//
//  Created by Zsombor Szabo on 12/07/2020.
//  
//

import SwiftUI

struct NextSteps: View {

    @EnvironmentObject var localStore: LocalStore

    @State var isShowingRegionSelection: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            if self.localStore.homeRiskLevel == .low {
                Text("HOME_NEXT_STEPS_PRE_MESSAGE")
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color("Text Color"))
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: .standardSpacing)
            }

            Text(verbatim: self.localStore.homeRiskLevel.nextStepsLocalizedDescription)
                .font(.custom("Montserrat-Semibold", size: 14))
                .foregroundColor(Color("Text Color"))
                .padding(.horizontal, 2 * .standardSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: .standardSpacing)

            ForEach(self.localStore.homeRiskLevel.nextSteps, id: \.self) { nextStep in

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

                            case .selectRegion:
                                self.isShowingRegionSelection.toggle()

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

                            Text(verbatim: parseNextStepDescription(description: nextStep.description) )
                                .foregroundColor(Color("Text Color"))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: .infinity, alignment: .leading)
                                .font(.custom("Montserrat-Regular", size: 14))

                            nextStep.type.image
                                .foregroundColor(Color("Tint Color"))
                        }
                        .padding(.standardSpacing)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemBackground))
                    }
                    .sheet(isPresented: self.$isShowingRegionSelection) {
                        RegionSelection(
                            selectedRegionIndex: self.localStore.selectedRegionIndex,
                            dismissOnFinish: true
                        ).environmentObject(self.localStore)
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
