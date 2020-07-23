//
//  Created by Zsombor Szabo on 01/06/2020.
//  
//

import SwiftUI

struct HowItWorksTitleText: View {

    let text: Text

    var body: some View {
        self.text
            .font(.custom("Montserrat-Regular", size: 14))
            .foregroundColor(Color("Text Color"))
            .padding(.horizontal, 2 * .standardSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//struct HowItWorksTitleText_Previews: PreviewProvider {
//    static var previews: some View {
//        HowItWorksTitleText()
//    }
//}
