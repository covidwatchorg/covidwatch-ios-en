//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct Alert: View {

    var message: String
    var backgroundColor: Color
    var showExclamation: Bool
    var detailImage: Image?

    init(message: String, backgroundColor: Color, showExclamation: Bool = true, detailImage: Image? = Image("Right Arrow")) {
        self.message = message
        self.backgroundColor = backgroundColor
        self.showExclamation = showExclamation
        self.detailImage = detailImage
    }

    var body: some View {
        HStack(spacing: 15) {
            if showExclamation {
                Image("Alert")
            }
            Text(verbatim: self.message)
                .font(.custom("Montserrat-SemiBold", size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
            if detailImage != nil {
                detailImage
            }
        }
        .padding(.vertical, .standardSpacing)
        .padding(.horizontal, 2 * .standardSpacing)
        .frame(minHeight: 70, alignment: .center)
        .background(self.backgroundColor.shadow(color: .init(white: 0.5), radius: 2, x: 0, y: 2))
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
