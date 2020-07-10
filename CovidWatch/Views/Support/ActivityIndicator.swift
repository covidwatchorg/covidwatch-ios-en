//
//  Created by Zsombor Szabo on 04/07/2020.
//  
//

import Foundation
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {

    public typealias UIView = UIActivityIndicatorView
    @Binding var isAnimating: Bool
    var configuration = { (indicator: UIView) in }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}
