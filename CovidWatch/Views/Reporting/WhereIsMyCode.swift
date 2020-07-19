//
//  Created by Zsombor Szabo on 17/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct WhereIsMyCode: View {
    @EnvironmentObject var localStore: LocalStore

    var body: some View {

        ZStack(alignment: .top) {

            ScrollView(.vertical, showsIndicators: false) {

                Spacer(minLength: .largeHeaderHeight)

                Text("WHERE_IS_MY_CODE_TITLE")
                    .modifier(StandardTitleTextViewModifier())
                    .padding(.horizontal, 2 * .standardSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: .standardSpacing)

                ForEach(self.localStore.region.nextStepsVerificationCode, id: \.self) { nextStep in

                    Group {
                        Spacer().frame(height: 10)

                        VStack(alignment: .center, spacing: 0) {

                            Group {

                                Spacer().frame(height: 2 * .standardSpacing)

                                Text(verbatim: nextStep.description)
                                    .foregroundColor(Color.primary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .font(.custom("Montserrat-Regular", size: 14))

                                Spacer().frame(height: 2 * .standardSpacing)

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
                                    Text("WHERE_IS_MY_CODE_CALL")
                                        .font(.custom("Montserrat-SemiBold", size: 14))
                                        .padding(.horizontal, 2 * .standardSpacing)
                                        .frame(minHeight: .callToActionSmallButtonHeight)
                                        .foregroundColor(.white)
                                        .background(Color("Tint Color"))
                                        .cornerRadius(.callToActionSmallButtonCornerRadius, antialiased: true)
                                }

                                Spacer().frame(height: 2 * .standardSpacing)
                            }
                            .padding(.horizontal, 2 * .standardSpacing)
                        }
                        .background(Color(UIColor.systemGray5))
                        .padding(.horizontal, 2 * .standardSpacing)
                    }

                }

                Spacer().frame(height: 2 * .standardSpacing)

                Text("WHERE_IS_MY_CODE_WHAT_IS_QUESTION")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer().frame(height: .standardSpacing)

                Text("WHERE_IS_MY_CODE_WHAT_IS_ANSWER")
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2 * .standardSpacing)

                Spacer().frame(height: .standardSpacing)
            }

            HeaderBar(showMenu: false, showDismissButton: true, showRegionSelection: true)
        }
    }
}

struct WhereIsMyCode_Previews: PreviewProvider {
    static var previews: some View {
        WhereIsMyCode()
    }
}
