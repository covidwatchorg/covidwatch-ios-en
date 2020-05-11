//
//  Created by Zsombor Szabo on 10/05/2020.
//  
//

import SwiftUI

struct ReportingCallCode: View {
    
    @EnvironmentObject var localStore: LocalStore
    
    @State var isShowingFinish = false
    
    let selectedTestResultIndex: Int
    
    init(selectedTestResultIndex: Int = 0) {
        self.selectedTestResultIndex = selectedTestResultIndex
    }
    
    var body: some View {
        
        if isShowingFinish {
            return AnyView(ReportingFinish())
        } else {
            return AnyView(
                ZStack(alignment: .top) {
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        VStack(spacing: 0) {
                            
                            ZStack(alignment: .bottom) {
                                
                                VStack(spacing: 0) {
                                    
                                    Text("Verify Your Positive Diagnosis")
                                        .font(.custom("Montserrat-SemiBold", size: 31))
                                        .foregroundColor(Color(red: 0.294, green: 0.039, blue: 0.439))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, .headerHeight)
                                        .padding(.horizontal, 2 * .standardSpacing)
                                    
                                    Spacer(minLength: 2 * .standardSpacing)
                                    
                                    Image("Woman Helpdesk")
                                }
                                
                                VStack(alignment: .center, spacing: 0) {
                                    Text("Verification Code")
                                        .font(.custom("Montserrat-Regular", size: 36))
                                        .foregroundColor(Color("Title Text Color"))
                                        .multilineTextAlignment(.center)
                                    Text(verbatim: self.localStore.testResults[selectedTestResultIndex].verificationCode)
                                        .font(.custom("Montserrat-Semibold", size: 36))
                                        .foregroundColor(Color("Title Text Color"))
                                }.padding(.horizontal, 2 * .standardSpacing)
                                    .frame(height: 172, alignment: .center)
                            }
                            .background(Image("Rectangle 22").resizable())
                            
                            Spacer(minLength: 2 * .standardSpacing)
                            
                            Text("Your positive diagnosis needs to be verified by a public health authority.")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("Title Text Color"))
                            
                            Button(action: {
                                
                                if let url = URL(string: "tel://1-800-000-0000") {
                                    
                                    if !UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.topViewController?.present(URLError(.badURL) as NSError, animated: true)
                                        return
                                    }
                                    
                                    UIApplication.shared.open(url, options: [:]) { (success) in
                                        if !success {
                                            UIApplication.shared.topViewController?.present(URLError(.badURL) as NSError, animated: true)
                                            return
                                        }
                                    }
                                }
                                
                            }) {
                                Text("Call 1-800-000-0000").modifier(SmallCallToAction())
                            }
                            .padding(.top, .standardSpacing)
                            .padding(.bottom, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            
                            Text("Done verifying the code?")
                                .modifier(SubCallToAction())
                                .padding(.horizontal, 2 * .standardSpacing)
                            
                            Button(action: {
                                self.confirmFinishCodeVerification()
                            }) {
                                Text("Finish Code Verification").modifier(SmallCallToAction())
                            }
                            .padding(.top, .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                            
                            Image("Powered By CW Grey")
                                .padding(.top, 2 * .standardSpacing)
                                .padding(.bottom, .standardSpacing)
                        }
                    }
                    
                    HeaderBar(showMenu: false, showDismissButton: true)
                }
            )
        }
    }
    
    func confirmFinishCodeVerification() {
        let alertController = UIAlertController(
            title: NSLocalizedString("Confirm you're finished verifying the code with the public health authority.", comment: ""),
            message: "",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: { _ in
                ()
        }))
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("Confirm", comment: ""),
            style: .default,
            handler: { _ in
                
                self.localStore.testResults[self.selectedTestResultIndex].isVerified = true
                self.isShowingFinish = true
        }))
        UIApplication.shared.topViewController?.present(alertController, animated: true)
    }
}

struct ReportingCallCode_Previews: PreviewProvider {
    static var previews: some View {
        ReportingCallCode()
    }
}
