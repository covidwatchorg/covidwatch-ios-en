//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct HowItWorksTitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Medium", size: 33))
            .foregroundColor(Color("Title Text Color"))            
            .padding(.horizontal, 2 * .standardSpacing)
    }
}
