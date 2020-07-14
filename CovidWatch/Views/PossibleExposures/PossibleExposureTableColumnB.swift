//
//  Created by Zsombor Szabo on 01/06/2020.
//  
//

import SwiftUI

struct PossibleExposureTableColumnB: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 32, maxHeight: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground))
            .border(Color("Button Border Color"), width: 1)
            .font(.custom("Montserrat-Regular", size: 14))
            .foregroundColor(Color.secondary)
    }
}
