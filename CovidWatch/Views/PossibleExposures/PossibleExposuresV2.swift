//
//  PossibleExposureV2.swift
//  CWBasics
//
//  Created by Andreas Ink on 7/10/20.
//  Copyright © 2020 Andreas Ink. All rights reserved.
//

import SwiftUI

struct PossibleExposureV2: View {
    @EnvironmentObject var row: Row
    @State var isToggled = false
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ZStack(alignment: .top) {
                        if row.isOpen {
                            ZStack {
                                Color("Drop Down Color")
                                    .frame(height: 12 * .standardSpacing)
                                VStack {
                                    Text("Raw Data")
                                        .font(.custom("Montserrat-Bold", size: 13))
                                        .foregroundColor(Color("Title Text Color"))
                                        .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                        .padding(.horizontal, .standardSpacing)
                                    HStack {
                                        Image("bullet")
                                        Text("Attenuation Durations: 30 min, 30 min, 30 min min")
                                            .font(.custom("Montserrat-Medium", size: 13))
                                            .foregroundColor(Color(.black))
                                    }  .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                        .padding(.horizontal, .standardSpacing)
                                    HStack {
                                        Image("bullet")
                                        Text("Attenuation Durations: 30 min, 30 min, 30 min min")
                                            .font(.custom("Montserrat-Medium", size: 13))
                                            .foregroundColor(Color(.black))
                                    }  .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                        .padding(.horizontal, .standardSpacing)
                                    HStack {
                                        Image("bullet")
                                        Text("Transmission Risk Level: 7 of 8")
                                            .font(.custom("Montserrat-Medium", size: 13))
                                            .foregroundColor(Color(.black))
                                    }  .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                        .padding(.horizontal, .standardSpacing)
                                    Button(action: {
                                        
                                    }) {
                                        Text("Learn More")
                                            .font(.custom("Montserrat-Medium", size: 12))
                                            .foregroundColor(Color("Learn More Color"))
                                            .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                            .padding(.horizontal, 2.2 * .standardSpacing)
                                    }
                                }
                            }
                            .padding(.top, 4.3 * .headerHeight)
                            .transition(.move(edge: .top))
                            .animation(.easeInOut(duration: 0.5))
                        }
                        Color(.white)
                            .frame(height: 4.2 * .headerHeight, alignment: .top)
                            .edgesIgnoringSafeArea(.top)
                        VStack {
                            Text("Possible Exposures")
                                .font(.custom("Montserrat-SemiBold", size: 24))
                                .foregroundColor(Color("Title Text Color"))
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .padding(.vertical, .standardSpacing)
                                .padding(.horizontal, .standardSpacing)
                            // swiftlint:disable:next line_length
                            Text("You will be notified of possible exposures to COVID-19. We recommend that this setting remain on until the national pandemic is over.")
                                .font(.custom("Montserrat-Regular", size: 13))
                                .foregroundColor(Color(.black))
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .padding(.vertical, .standardSpacing)
                                .padding(.horizontal, .standardSpacing)
                            HStack {
                                Toggle(isOn: $isToggled) {
                                    Text("Exposure Notifications")
                                        .font(.custom("Montserrat-SemiBold", size: 24))
                                        .foregroundColor(Color("Subtitle Text Color"))
                                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                }
                                Text("on")
                            } .padding(.horizontal, .standardSpacing)
                            ZStack(alignment: .center) {
                                Color("Last Checked Header Color")
                                    .frame(height: .headerHeight)
                                    .edgesIgnoringSafeArea(.leading)
                                Text("Last checked: July 9, 2020 at 5:00pm")
                                    .font(.custom("Montserrat-Bold", size: 14))
                                    .foregroundColor(Color(.white))
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                    .padding(.horizontal, .standardSpacing)
                            }
                            PossibleExposureRowV2()
                                .padding(.horizontal, .standardSpacing)
                                .padding(.top, .standardSpacing)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 4 * .standardSpacing)
            .edgesIgnoringSafeArea(.top)
            ZStack {
                Color(.white)
                    .frame(height: .headerHeight, alignment: .bottom)
                    .edgesIgnoringSafeArea(.bottom)
                Text("Each exposure notification is saved in this app and will be automatically deleted after 30 days.")
                    .font(.custom("Montserrat-Regular", size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.black))
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                    .padding(.horizontal, .standardSpacing)
            } .padding(.top, 7.5 * .headerHeight)
        }
    }
}

struct PossibleExposureV2_Previews: PreviewProvider {
    static var previews: some View {
        PossibleExposureV2()
    }
}

struct PossibleExposureRowV2: View {
    @EnvironmentObject var row: Row
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Image("Exposure Row High Risk")
                        Text("High Risk")
                            .font(.custom("Montserrat-Bold", size: 13))
                            .foregroundColor(Color("Title Text Color"))
                            .padding(.leading, .standardSpacing)
                        Text("July 10, 2020")
                            .font(.custom("Montserrat", size: 16))
                            .foregroundColor(Color("Title Text Color"))
                            .padding(.horizontal, .standardSpacing)
                        Spacer(minLength: .standardSpacing)
                        Button(action: {
                            withAnimation {
                                self.row.isOpen.toggle()
                            }
                        }) {
                            Image("down")
                                .padding(.horizontal, .standardSpacing)
                        }
                    }
                }
            }
        }
    }
}
class Row: ObservableObject {
    @Published var isOpen = false
}
