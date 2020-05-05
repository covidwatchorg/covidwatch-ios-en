//
//  Created by Zsombor Szabo on 05/05/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct Advice: View {
    
    let showGetTestedAdvice: Bool
    
    init(showGetTestedAdvice: Bool = false) {
        self.showGetTestedAdvice = showGetTestedAdvice
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 2 * .standardSpacing) {
                Image("Advice Checkmark")
                Text("Monitor symptoms")
                    .modifier(SubtitleText())
                Spacer()
            }
            HStack(spacing: 2 * .standardSpacing) {
                Image("Advice Checkmark")
                Text("Isolate from others")
                    .modifier(SubtitleText())
                Spacer()
            }
            HStack(spacing: 2 * .standardSpacing) {
                Image("Advice Checkmark")
                Text("Rest and take care")
                    .modifier(SubtitleText())
                Spacer()
            }
            if showGetTestedAdvice {
                HStack(spacing: 2 * .standardSpacing) {
                    Image("Advice Checkmark")
                    Text("Get tested if advised")
                        .modifier(SubtitleText())
                    Spacer()
                }
            }
            HStack(spacing: 2 * .standardSpacing) {
                Image("Advice Checkmark")
                Text("Refer to local agencies for medical advice")
                    .modifier(SubtitleText())
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct Advice_Previews: PreviewProvider {
    static var previews: some View {
        Advice()
    }
}
