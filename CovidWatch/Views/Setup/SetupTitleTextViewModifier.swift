//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct SetupTitleTextViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-SemiBold", size: 36))
            .foregroundColor(Color("Title Text Color"))            
    }
}
