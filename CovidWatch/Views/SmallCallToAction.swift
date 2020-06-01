//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct SmallCallToAction: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Bold", size: 18))
            .frame(maxWidth: .infinity, minHeight: .callToActionSmallButtonHeight)
            .foregroundColor(.white)
            .background(Color("Tint Color"))
            .cornerRadius(.callToActionSmallButtonCornerRadius, antialiased: true)
    }
}
