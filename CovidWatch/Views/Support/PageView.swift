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
        VStack{
       
            
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            
       
              ZStack(alignment: .bottom){
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
            
            
            HStack(spacing: .standardSpacing * 20){
                              Button(action: {
                                  print("CW")
                                 if self.currentPage != 0 {
                                self.currentPage -= 1
                                }
                                  print(self.currentPage)
                               
                                  
                                
                               
                              }) {
                               
                                  Image("Left Arrow PageView")
                                  
                              }
                              
                              Button(action: {
                                print("CW")
                                  if self.currentPage != 3 {
                                  self.currentPage += 1
                                }
                                   print(self.currentPage)
                              }) {
                                                 Image("Right Arrow PageView")
                                             }
                   }
                 .frame(minWidth: 0, maxWidth: .standardSpacing * 3, minHeight: 0, maxHeight: .standardSpacing * 3, alignment: .center)
                
            
           
        
        }.padding(.bottom, .standardSpacing * 6)
    }
}
}
