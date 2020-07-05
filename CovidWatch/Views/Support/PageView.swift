/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A view for bridging a UIPageViewController.
 */

import SwiftUI

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0
    init(_ views: [Page]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }
    var body: some View {
        
        VStack {
            
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            ZStack(alignment: .bottom) {
                BlurView(style: .systemChromeMaterial)
                    
                    .edgesIgnoringSafeArea(.bottom)
                    // swiftlint:disable:next line_length
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .headerHeight, alignment: .bottomLeading)
                
                PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
                HStack(spacing: .standardSpacing * 20) {
                    Button(action: {
                        if self.currentPage != 0 {
                            self.currentPage -= 1
                        } else {
                            self.currentPage = self.viewControllers.count - 1
                        }
                        
                    }) {
                        Image("Left Arrow PageView")
                            .frame(width: 50, height: 50)
                    }
                    Button(action: {
                        if self.currentPage != self.viewControllers.count - 1 {
                            self.currentPage += 1
                        } else {
                            
                            self.currentPage = 0
                        }
                    }) {
                        Image("Right Arrow PageView")
                            .frame(width: 50, height: 50)
                    }
                } .padding(.vertical, .standardSpacing )
                    // swiftlint:disable:next line_length
                    .frame(minWidth: 0, maxWidth: .standardSpacing * 3, minHeight: 0, maxHeight: .standardSpacing * 3, alignment: .center).zIndex(2)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
