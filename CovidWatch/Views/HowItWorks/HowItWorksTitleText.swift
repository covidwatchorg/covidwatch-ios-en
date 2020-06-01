//
//  Created by Zsombor Szabo on 01/06/2020.
//  
//

import SwiftUI

struct HowItWorksTitleText: View {
    var body: some View {
        Text(verbatim: NSLocalizedString("HOW_IT_WORKS_TITLE", comment: "").uppercased())
            .font(.custom("Montserrat-Regular", size: 14))
            .foregroundColor(Color("Title Text Color"))
            .padding(.horizontal, 2 * .standardSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HowItWorksTitleText_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorksTitleText()
    }
}
