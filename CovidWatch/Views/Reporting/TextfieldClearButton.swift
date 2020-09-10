//
//  TextfieldClearButton.swift
//  CovidWatch-Arizona-Dev
//
//  Created by Rajat Sharma on 10/09/20.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct TextfieldClearButton: ViewModifier {
    @Binding var text: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if !self.text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .frame(width: 50, height: 35, alignment: .trailing)
                .padding(.trailing, (2 * .standardSpacing) + 10)
                .contentShape(Rectangle())
            }
        }
    }
}
