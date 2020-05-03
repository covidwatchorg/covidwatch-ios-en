//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct TopBar: View {
    var body: some View {
        HStack {
            Image("Covid Watch Brandmark")
            Spacer()
            Image("menu")
        }
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar()
    }
}
