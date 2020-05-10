//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct SmallCallToAction: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Bold", size: 18))
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color("Tint Color"))
            .cornerRadius(.smallButtonCornerRadius)
    }
}
