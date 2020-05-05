//
//  Created by Zsombor Szabo on 03/05/2020.
//  
//

import SwiftUI

struct TopBar: View {
    
    let showMenu: Bool
    let showDismissButton: Bool
    
    @EnvironmentObject var userData: UserData
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(showMenu: Bool = true, showDismissButton: Bool = false) {
        self.showMenu = showMenu
        self.showDismissButton = showDismissButton
    }
    
    var body: some View {
        HStack {
            Image("Covid Watch Brandmark")
            Spacer()
            if self.showMenu {
                Button(action: {
                    self.userData.isShowingMenu.toggle()
                }) {
                    Image("Menu Button").frame(minWidth: 44, minHeight: 44)
                }.sheet(isPresented: self.$userData.isShowingMenu) { Menu().environmentObject(self.userData) }
            }
            if self.showDismissButton {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image("Dismiss Button")
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .padding(.top, 2 * .standardSpacing)
        .padding(.horizontal, 2 * .standardSpacing)
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar()
    }
}
