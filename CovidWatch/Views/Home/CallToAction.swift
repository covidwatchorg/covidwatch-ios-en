//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct CallToAction: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Bold", size: 18))
            .frame(maxWidth: .infinity, minHeight: .callToActionButtonHeight)
            .foregroundColor(.white)
            .background(Color("Tint Color"))
            .cornerRadius(.callToActionButtonCornerRadius, antialiased: true)
    }
}
