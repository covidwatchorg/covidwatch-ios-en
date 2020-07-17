//
//  Created by Zsombor Szabo on 17/07/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import SwiftUI

struct SelectedRegion: View {

    @State var isShowingRegionSelection: Bool = false

    @EnvironmentObject var userData: UserData

    @EnvironmentObject var localStore: LocalStore

    var body: some View {
        HStack {
            Text("SELECTED_REGION")
                .font(.custom("Montserrat-Semibold", size: 12))
                .foregroundColor(Color.secondary)
            Button(action: {
                self.isShowingRegionSelection.toggle()
            }) {
                Text(self.userData.region.name)
                    .font(.custom("Montserrat-Semibold", size: 12))
                    .foregroundColor(Color("Tint Color"))
                    .underline()
            }.sheet(isPresented: self.$isShowingRegionSelection) {
                RegionSelection(
                    selectedRegionIndex: self.userData.selectedRegionIndex,
                    dismissOnFinish: true
                )
                    .environmentObject(self.userData)
                    .environmentObject(self.localStore)
            }
        }
    }
}

struct SelectedRegion_Previews: PreviewProvider {
    static var previews: some View {
        SelectedRegion()
    }
}
