//
//  Created by Zsombor Szabo on 01/06/2020.
//  
//

import SwiftUI

struct HowItWorksSubtitleText: View {

    let text: Text

    var body: some View {
        self.text
            .font(.custom("Montserrat-SemiBold", size: 24))
            .foregroundColor(Color("Text Color"))
            .padding(.horizontal, 2 * .standardSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HowItWorksSubtitleText_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorksSubtitleText(text: Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/))
    }
}
