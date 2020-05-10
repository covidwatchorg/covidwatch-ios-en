//
//  Created by Zsombor Szabo on 03/05/2020.
//

import Foundation
import CoreGraphics

extension CGFloat {
    
    public static let standardSpacing: CGFloat = 12
    public static let headerHeight: CGFloat = 80
    public static let stickyFooterHeight: CGFloat = .standardSpacing + .callToActionSmallButtonHeight + 5 + .callToActionSmallButtonHeight + 2 * .standardSpacing + .standardSpacing
    public static let callToActionButtonHeight: CGFloat = 58
    public static let callToActionSmallButtonHeight: CGFloat = 40
    public static let paddingLargeHeight: CGFloat = 9 * standardSpacing
    public static let buttonCornerRadius: CGFloat = 10
    //public static let smallButtonCornerRadius: CGFloat = 5
    public static let smallButtonCornerRadius: CGFloat = 13
}
