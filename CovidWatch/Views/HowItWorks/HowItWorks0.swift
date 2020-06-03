//
//  Created by Zsombor Szabo on 04/05/2020.
//  
//

import SwiftUI

struct HowItWorks0: View {
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Spacer(minLength: .headerHeight)
                
                Image("Family Dancing")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibility(label: Text("WELCOME_IMAGE_ACCESSIBILITY_LABEL"))
                    .background(
                        Image("Rectangle 33")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .accessibility(hidden: true)
                )
                
                Spacer(minLength: .standardSpacing)
                
                Text(verbatim: String.localizedStringWithFormat(NSLocalizedString("WELCOME_TITLE", comment: ""), (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""))
                    .font(.custom("Montserrat-Semibold", size: 26))
                    .foregroundColor(Color("Title Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Spacer(minLength: 2 * .standardSpacing)
                
                Text("WELCOME_MESSAGE")
                    .font(.custom("Montserrat-Regular", size: 18))
                    .foregroundColor(Color("Title Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2 * .standardSpacing)
                
                Spacer(minLength: 32 + .standardSpacing)
            }
        }
    }
}

struct HowItWorks0_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks0()
    }
}
