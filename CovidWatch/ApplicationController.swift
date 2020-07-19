//
//  Created by Zsombor Szabo on 04/05/2020.
//

import Foundation
import UIKit
import Combine
import ExposureNotification
import CommonCrypto
import SwiftUI
import ZIPFoundation

class ApplicationController: NSObject {

    static let shared = ApplicationController()

    var userNotificationsObserver: NSObjectProtocol?
    var exposureNotificationEnabledObservation: NSKeyValueObservation?
    var exposureNotificationStatusObservation: NSKeyValueObservation?

    override init() {
        super.init()

        if LocalStore.shared.firstRun {
            LocalStore.shared.firstRun = false
        }

        self.configureExposureNotificationStatusObserver()
        self.configureExposureNotificationEnabledObserver()
        self.configureUserNotificationStatusObserver()
    }

    func configureExposureNotificationStatusObserver() {
        self.exposureNotificationStatusObservation = ExposureManager.shared.manager.observe(
            \.exposureNotificationStatus, options: [.initial, .new]
        ) { (_, _) in

            DispatchQueue.main.async {
                withAnimation {
                    if self.checkENManagerAuthorizationStatus() {
                        LocalStore.shared.exposureNotificationStatus = ExposureManager.shared.manager.exposureNotificationStatus
                    }
                }
            }
        }
    }

    func configureExposureNotificationEnabledObserver() {
        self.exposureNotificationEnabledObservation = ExposureManager.shared.manager.observe(
            \.exposureNotificationEnabled, options: [.initial, .new]
        ) { (_, _) in

            DispatchQueue.main.async {
                withAnimation {
                    if self.checkENManagerAuthorizationStatus() {
                        LocalStore.shared.exposureNotificationEnabled =
                            ExposureManager.shared.manager.exposureNotificationEnabled
                    }
                }
            }
        }
    }

    func checkENManagerAuthorizationStatus() -> Bool {
        switch ENManager.authorizationStatus {
            case .restricted:
                LocalStore.shared.exposureNotificationStatus = .restricted
                LocalStore.shared.exposureNotificationEnabled = false
                return false
            case .notAuthorized:
                LocalStore.shared.exposureNotificationStatus = .disabled
                LocalStore.shared.exposureNotificationEnabled = false
                return false
            default:
             ()
        }
        return true
    }

    func configureUserNotificationStatusObserver() {
        self.userNotificationsObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in

            self?.checkNotificationPersmission()
        }
    }

    func checkNotificationPersmission() {
        UNUserNotificationCenter.current().getNotificationSettings(
            completionHandler: { (settings) in

                DispatchQueue.main.async {
                    withAnimation {
                        LocalStore.shared.notificationsAuthorizationStatus =
                            settings.authorizationStatus
                    }
                }
        })
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) else {
                return
        }
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }

    func handleExposureNotificationEnabled(error: Error) {
        let nsError = error as NSError
        if nsError.domain == ENErrorDomain, nsError.code == ENError.notAuthorized.rawValue {
            let alertController = UIAlertController(
                title: NSLocalizedString("ERROR", comment: ""),
                message: NSLocalizedString("ACCES_TO_EN_DENIED", comment: "Error"),
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("CANCEL", comment: ""),
                style: .cancel,
                handler: nil)
            )
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("SETTINGS", comment: ""),
                style: .default,
                handler: { (_) in
                    ApplicationController.shared.openSettings()
                })
            )
            UIApplication.shared.topViewController?.present(alertController, animated: true)
        } else {
            UIApplication.shared.topViewController?.present(
                error,
                animated: true,
                completion: nil
            )
        }
    }

    @objc func handleTapShareApp(url: URL = URL(string: "https://www.covidwatch.org")!) {
        let text = NSLocalizedString("SHARE_THE_APP_SHEET_MESSAGE", comment: "")

        let itemsToShare: [Any] = [text, url as Any]
        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )

        // so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView =
            UIApplication.shared.topViewController?.view

        // present the view controller
        UIApplication.shared.topViewController?.present(
            activityViewController,
            animated: true,
            completion: nil
        )
    }

    func exportExposures() {
        let alertController = UIAlertController(
            title: NSLocalizedString("Export Possible Exposures for Test Case", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { (textField) in
            textField.text = ""
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CONTINUE", comment: ""), style: .default, handler: { _ in
            guard let text = alertController.textFields?.first?.text else { return }
            self.exportExposures(forTestCase: text)
        }))
        UIApplication.shared.topViewController?.present(alertController, animated: true)
    }

    func exportExposures(forTestCase testCase: String) {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = "\(UIDevice.current.name)_\(ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withInternetDateTime]))_\(testCase)"
        let possibleExposuresPath = cachesDirectory.appendingPathComponent("\(fileName).json")
        do {
            let json = try JSONEncoder().encode(
                PossibleExposureInfosExport(
                    possibleExposureInfos: LocalStore.shared.exposuresInfos,
                    region: LocalStore.shared.region
                )
            )
            try json.write(to: possibleExposuresPath)
            let activityViewController = UIActivityViewController(activityItems: [possibleExposuresPath], applicationActivities: nil)
            activityViewController.setValue(fileName, forKey: "Subject")
            UIApplication.shared.topViewController?.present(
                activityViewController,
                animated: true,
                completion: nil
            )
        } catch {
            UIApplication.shared.topViewController?.present(
                error as NSError,
                animated: true,
                completion: nil
            )
        }
    }

    func defaultRegionJSON() {
        let regions = CodableRegion.all
        if let data = try? JSONEncoder().encode(regions) {
            print(String(data: data, encoding: .utf8)!)
        }
    }
}
