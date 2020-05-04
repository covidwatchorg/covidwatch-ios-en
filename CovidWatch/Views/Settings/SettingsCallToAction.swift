//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct SettingsCallToAction: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Bold", size: 18))
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(Color("Settings Button Text Color"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Settings Button Border Color"), lineWidth: 2)
        )
    }
}
