//
//  Created by Zsombor SZABO on 13/10/2016.
//

import UIKit
import ExposureNotification

extension UIViewController {

    public func present(
        nsError: NSError,
        title: String? = NSLocalizedString("ERROR", comment: ""),
        swapTitleAndMessage swapFlag: Bool = false,
        animated flag: Bool,
        completion: (() -> Swift.Void)? = nil
    ) {
        var messages = [String]()
        messages.append(nsError.localizedDescription)
        if let suggestion = nsError.localizedRecoverySuggestion {
            messages.append(suggestion)
        }
        let message = messages.joined(separator: "\n")

        let alertController = UIAlertController(
            title: swapFlag ? message : title,
            message: swapFlag ? title : message,
            preferredStyle: .alert
        )
        if let options = nsError.localizedRecoveryOptions,
            let recoveryAttempter = nsError.recoveryAttempter {
            for (index, option) in options.enumerated() {
                let action = UIAlertAction(
                    title: option,
                    style: .default,
                    handler: { (_) in
                        _ = (recoveryAttempter as AnyObject).attemptRecovery(
                            fromError: nsError,
                            optionIndex: index
                        )
                })
                alertController.addAction(action)
            }
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("CANCEL", comment: ""),
                style: .cancel,
                handler: nil)
            )
        } else {
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default,
                handler: nil)
            )
        }
        present(alertController, animated: flag, completion: completion)
    }

    public func present(
        _ error: Error,
        animated: Bool,
        completion: (() -> Swift.Void)? = nil
    ) {
        if let error = error as? ENError,
            let message = (error).userInfo["cuErrorMsg"] as? String {
            self.present(
                message: message,
                animated: animated,
                completion: completion
            )
        } else {
            self.present(
                nsError: error as NSError,
                animated: animated,
                completion: completion
            )
        }
    }

    public func present(
        title: String? = NSLocalizedString("ERROR", comment: ""),
        message: String? = nil,
        recoveryAction: UIAlertAction? = nil,
        animated flag: Bool,
        completion: (() -> Swift.Void)? = nil
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default,
            handler: nil)
        )

        if let action = recoveryAction {
            alertController.addAction(action)
        }

        present(alertController, animated: flag, completion: completion)
    }
}
