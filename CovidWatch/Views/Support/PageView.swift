/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view for bridging a UIPageViewController.
*/

import SwiftUI

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0
    @State var forwardAnimation = true

    init(_ views: [Page]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage, forwardAnimation: $forwardAnimation)

            HStack(spacing: 0) {
                Button(action: {
                    if self.currentPage > 0 {
                        self.currentPage -= 1
                        self.forwardAnimation = false
                    }
                }) {
                    Image("Page Control Left")
                        .accessibility(label: Text("HOW_IT_WORKS_PAGE_CONTROL_PREVIOUS_BUTTON_ACCESSIBILITY_LABEL"))
                        .accessibility(hint: Text("HOW_IT_WORKS_PAGE_CONTROL_PREVIOUS_BUTTON_ACCESSIBILITY_HINT"))
                        .padding(.standardSpacing)
                }
                Spacer().frame(width: 66)
                PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
                Spacer().frame(width: 66)
                Button(action: {
                    if self.currentPage < self.viewControllers.count - 1 {
                        self.currentPage += 1
                        self.forwardAnimation = true
                    }
                }) {
                    Image("Page Control Right")
                        .accessibility(label: Text("Next"))
                        .accessibility(hint: Text("HOW_IT_WORKS_PAGE_CONTROL_NEXT_BUTTON_ACCESSIBILITY_HINT"))
                        .padding(.standardSpacing)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(BlurView(style: .systemChromeMaterial).edgesIgnoringSafeArea(.all))
        }
    }
}
