//
//  Created by Zsombor Szabo on 08/06/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct PossibleExposureSummaryValueViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Montserrat-ExtraBold", size: 18))
            .foregroundColor(.white)
            .frame(minWidth: 54, minHeight: 33, alignment: .center)            
    }
}
