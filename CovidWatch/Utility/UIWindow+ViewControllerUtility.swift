//
//  Created by Zsombor Szabo on 11/03/2020.
//

import UIKit

extension UIApplication {

    public func topViewController(_ inWindow: UIWindow?) -> UIViewController? {
        if var viewController = inWindow?.rootViewController {
            while viewController.presentedViewController != nil {
                viewController = viewController.presentedViewController!
            }
            return viewController
        }
        return nil
    }

    public var topViewController: UIViewController? {
        #if AppExtension
            return nil
        #else
            return topViewController(UIApplication.shared.windows.filter({$0.isKeyWindow}).first)
        #endif
    }

    public var visibleViewControllers: [UIViewController]? {
        #if AppExtension
            return nil
        #else
            if let topViewController = topViewController {
                return topViewController.visibleViewControllers
            }
            return nil
        #endif
    }
}

extension UIViewController {

    public var visibleViewControllers: [UIViewController] {

        // Special case when self is navigation controller
        if let navigationController = self as? UINavigationController {
            if let lastViewController = navigationController.viewControllers.last {
                return [lastViewController]
            }
        }

        // Recursion part
        if !children.isEmpty {
            var result = [UIViewController]()
            for childViewController in children {
                result.append(contentsOf: childViewController.visibleViewControllers)
            }
            return result
        }

        return [self]
    }
}
