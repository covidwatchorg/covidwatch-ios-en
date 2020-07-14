//
//  Created by Zsombor Szabo on 01/06/2020.
//  
//

import SwiftUI

struct PossibleExposureTableColumnA: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 32, maxHeight: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .border(Color("Button Border Color"), width: 1)
            .font(.custom("Montserrat-Bold", size: 14))
            .foregroundColor(Color.primary)
    }
}
