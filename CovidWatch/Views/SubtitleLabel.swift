//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct SubtitleLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Regular", size: 18))
            .foregroundColor(Color("subtitleLabel"))
            .frame(maxWidth: .infinity, alignment: .leading)            
            .padding(.horizontal, 2 * .standardSpacing)
    }
}
