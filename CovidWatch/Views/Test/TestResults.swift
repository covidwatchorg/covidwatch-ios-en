//
//  Created by Zsombor Szabo on 05/05/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI
import Combine

struct TestResults: View {
    
    @EnvironmentObject var userData: UserData
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isSelectedNotTestedOrNegative: Bool = false
    
    @State var isSelectedYesTestedPositive: Bool = false
    
    @State var isPickingDate: Bool = false
    
    @State var isConfirming: Bool = false
    
    let rkManager: RKManager = RKManager(
        calendar: Calendar.current,
        minimumDate: Date().addingTimeInterval(-60*60*24*60),
        maximumDate: Date(),
        selectedDates: [],
        mode: 0
    )
    
    init() {
        rkManager.selectedDate = Date()
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
        
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                Spacer(minLength: .paddingLargeHeight)
                
                if userData.daysSinceLastExposure != 0 {
                    
                    PotentialRisk()
                        .padding(.horizontal, 2 * .standardSpacing)
                        .padding(.bottom, .standardSpacing)
                    
                    Advice(showGetTestedAdvice: true)
                        .padding(.horizontal, 4 * .standardSpacing)
                        .padding(.bottom, 2 * .standardSpacing)
                }
                else {
                    
                }
                
                Text("Have you tested positive for COVID-19?")
                    .modifier(TestResultsTitleText())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2 * .standardSpacing)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                if isConfirming {
                    
                    // TODO
                
                } else {
                    Button(action: {
                        self.isSelectedNotTestedOrNegative = true
                        self.isSelectedYesTestedPositive = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Not Tested or Negative")
                            Spacer()
                            if isSelectedNotTestedOrNegative {
                                Image("Test Button Checkmark")
                            }
                            else {
                                Image("Settings Button Checkmark")
                            }
                        }.modifier(TestResultsCallToAction(
                            borderColor: !isSelectedNotTestedOrNegative ?
                                Color("Settings Button Border Color") :
                                Color("Tint Color")
                            )
                        )
                    }
                    .frame(height: .callToActionButtonHeight)
                    .padding(.horizontal, 2 * .standardSpacing)
                    
                    Button(action: {
                        self.isSelectedYesTestedPositive = true
                        self.isSelectedNotTestedOrNegative = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Yes, Tested Positive")
                            Spacer()
                            if isSelectedYesTestedPositive {
                                Image("Test Button Checkmark")
                            }
                            else {
                                Image("Settings Button Checkmark")
                            }
                        }.modifier(TestResultsCallToAction(
                            borderColor: !isSelectedYesTestedPositive ?
                                Color("Settings Button Border Color") :
                                Color("Tint Color")
                            )
                        )
                    }
                    .frame(height: .callToActionButtonHeight)
                    .padding(.horizontal, 2 * .standardSpacing)
                    
                    if isSelectedNotTestedOrNegative {
                        Text("Thanks for the update. You can come back here if you test positive to help keep your community safe.")
                            .modifier(SubtitleText())
                            .padding(.top, .paddingLargeHeight)
                            .padding(.horizontal, 2 * .standardSpacing)
                        
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue").modifier(CallToAction())
                        }.frame(minHeight: .callToActionButtonHeight)
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.bottom, .standardSpacing + 44)
                            .padding(.horizontal, 2 * .standardSpacing)
                    }
                    
                    if isSelectedYesTestedPositive {
                        
                        Text("When did your symptoms start?")
                            .modifier(SubtitleText())
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                        
                        Button(action: {
                            self.isPickingDate = true
                        }) {
                            HStack {
                                Spacer()
                                Text(verbatim: dateFormatter.string(from: self.rkManager.selectedDate ?? Date()))
                                Spacer()
                                Image("Test Button Checkmark")
                            }.modifier(TestResultsCallToAction(borderColor: Color("Tint Color")))
                        }
                        .sheet(
                            isPresented: $isPickingDate,
                            content: {
                                RKViewController(isPresented: self.$isPickingDate, rkManager: self.rkManager)
                        }).frame(height: .callToActionButtonHeight)
                            .padding(.horizontal, 2 * .standardSpacing)
                        
                        Button(action: {
                            self.userData.lastReportDate = Date()
                            self.userData.isAfterSubmitReport = true
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Report").modifier(CallToAction())
                        }.frame(minHeight: .callToActionButtonHeight)
                            .padding(.top, 2 * .standardSpacing)
                            .padding(.horizontal, 2 * .standardSpacing)
                        
                        Text("By clicking \"Report\", you acknowledge, understand and further agree to our Privacy Policy and Terms & Conditions.")
                            .modifier(SubCallToAction())
                            .padding(.horizontal, 2 * .standardSpacing)
                            .padding(.top, .standardSpacing)
                            .padding(.bottom, .standardSpacing)
                    }
                }

            }
            
            TopBar(showMenu: false, showDismissButton: true)
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        TestResults()
    }
}
