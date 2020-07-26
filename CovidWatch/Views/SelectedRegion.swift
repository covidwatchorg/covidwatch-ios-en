//
//  Created by Zsombor Szabo on 17/07/2020.
//  
//

import SwiftUI

struct SelectedRegion: View {

    @State var isShowingRegionSelection: Bool = false

    @EnvironmentObject var localStore: LocalStore

    var body: some View {
        HStack {
            Text("SELECTED_REGION")
                .font(.custom("Montserrat-Medium", size: 12))
                .foregroundColor(Color("Text Color"))
            Button(action: {
                self.isShowingRegionSelection.toggle()
            }) {
                Text(self.localStore.region.name)
                    .font(.custom("Montserrat-Medium", size: 12))
                    .foregroundColor(Color("Tint Color"))
                    .underline()
                    .frame(minHeight: .minTappableTargetDimension)
            }.sheet(isPresented: self.$isShowingRegionSelection) {
                RegionSelection(
                    selectedRegionIndex: self.localStore.selectedRegionIndex,
                    dismissOnFinish: true
                ).environmentObject(self.localStore)
            }
        }
    }
}

struct SelectedRegion_Previews: PreviewProvider {
    static var previews: some View {
        SelectedRegion()
    }
}
