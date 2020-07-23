//
//  Created by Zsombor Szabo on 01/06/2020.
//  
//

import SwiftUI

struct HowItWorksMessageText: View {

    let text: Text

    var body: some View {
        self.text
            .font(.custom("Montserrat-Regular", size: 16))
            .foregroundColor(Color("Text Color"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2 * .standardSpacing)
    }
}

struct HowItWorksMessageText_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorksMessageText(text: Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/))
    }
}
