//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Alert: View {
    
    var message: String
    var backgroundColor: Color
    
    init(message: String, backgroundColor: Color) {
        self.message = message
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image("Alert")
            Text(verbatim: self.message)
                .font(.custom("Montserrat-Bold", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
            Image("Right Arrow")
        }
        .padding(.horizontal, 2 * .standardSpacing)  
        .frame(height: 130, alignment: .center)
        .background(self.backgroundColor)
    }
}

struct Alert_Previews: PreviewProvider {
    static var previews: some View {
        Alert(
            message: "Hello, World!",
            backgroundColor: .red
        )
            .previewLayout(.fixed(width: 375, height: 130))
    }
}
