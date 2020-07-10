//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import Foundation
import SwiftUI

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(visualEffectView)
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurView>) {
    }
}

struct VibrancyView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    let image: UIImage

    func makeUIView(context: UIViewRepresentableContext<VibrancyView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        let layoutView = UIView()
        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.backgroundColor = .clear
        view.addSubview(layoutView)

        let blurEffect = UIBlurEffect(style: style)

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vibrancyEffectView.frame = view.bounds

        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        vibrancyEffectView.contentView.addSubview(imageView)

        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        view.addSubview(blurredEffectView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: layoutView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: layoutView.centerYAnchor),
            layoutView.topAnchor.constraint(equalTo: view.topAnchor),
            layoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            layoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VibrancyView>) {
    }
}
