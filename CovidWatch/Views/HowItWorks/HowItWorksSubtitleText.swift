//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct HowItWorksSubtitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Regular", size: 18))
            .foregroundColor(Color("Title Text Color"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
