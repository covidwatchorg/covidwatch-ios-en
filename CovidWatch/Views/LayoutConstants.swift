//
//  Created by Zsombor Szabo on 03/05/2020.
//

import Foundation
import CoreGraphics

extension CGFloat {

    public static let standardSpacing: CGFloat = 12
    public static let headerHeight: CGFloat = 56
    public static let footerHeight: CGFloat = 44
    public static let largeHeaderHeight: CGFloat = 2 * minTappableTargetDimension
    public static let stickyFooterHeight: CGFloat = .standardSpacing + .callToActionSmallButtonHeight + 5 + .callToActionSmallButtonHeight + .standardSpacing
    public static let minTappableTargetDimension: CGFloat = 44
    public static let callToActionButtonHeight: CGFloat = 58
    public static let callToActionButtonCornerRadius: CGFloat = 5
    public static let callToActionSmallButtonHeight: CGFloat = minTappableTargetDimension
    public static let callToActionSmallButtonCornerRadius: CGFloat = 5
}
