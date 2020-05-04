/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view wrapping a UIPageControl.
*/

import SwiftUI

import UIKit

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.transform = CGAffineTransform(scaleX: 20.0 / 7.0, y: 20.0 / 7.0)
        control.pageIndicatorTintColor = UIColor(named: "Page Indicator Tint Color")
        control.currentPageIndicatorTintColor = UIColor(named: "Tint Color")
        control.numberOfPages = numberOfPages
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    class Coordinator: NSObject {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }

        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
