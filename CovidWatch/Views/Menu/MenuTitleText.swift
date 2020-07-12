//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct MenuTitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-SemiBold", size: 18))
            .foregroundColor(Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 22)
            .padding(.bottom, 16)
    }
}
