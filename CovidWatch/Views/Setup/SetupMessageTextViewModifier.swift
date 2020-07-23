//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct SetupMessageTextViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Regular", size: 16))
            .foregroundColor(Color("Text Color"))
    }
}
