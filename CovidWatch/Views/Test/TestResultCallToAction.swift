//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct TestResultsCallToAction: ViewModifier {
    
    let borderColor: Color
    
    init(borderColor: Color) {
        self.borderColor = borderColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-Bold", size: 18))
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(Color("Settings Button Text Color"))
            .overlay(
                RoundedRectangle(cornerRadius: .buttonCornerRadius)
                    .stroke(self.borderColor, lineWidth: 2)
        )
    }
}
