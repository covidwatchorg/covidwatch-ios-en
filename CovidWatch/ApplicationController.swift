//
//  Created by Zsombor Szabo on 04/05/2020.
//

import Foundation
import UIKit
import Combine
import ExposureNotification

import SwiftUI

class ApplicationController: NSObject {
    
    static let shared = ApplicationController()
    
    var userNotificationsObserver: NSObjectProtocol?
    var exposureNotificationStatusObservation: NSKeyValueObservation? = nil
    
    override init() {
        super.init()
        
        if UserData.shared.firstRun {
            UserData.shared.firstRun = false
        }
        
        self.configureExposureNotificationStatusObserver()
        self.configureUserNotificationStatusObserver()
    }
    
    func configureExposureNotificationStatusObserver() {
        self.exposureNotificationStatusObservation = ExposureManager.shared.manager.observe(
            \.exposureNotificationStatus, options: [.initial, .old, .new]
        ) { (_, change) in
            
            DispatchQueue.main.async {
                withAnimation {
                    UserData.shared.exposureNotificationStatus =
                        change.newValue ?? .unknown
                }
            }
        }
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
                        UserData.shared.notificationsAuthorizationStatus =
                            settings.authorizationStatus
                    }
                }
        })
    }
    
    @objc func shareApp() {
        let text = NSLocalizedString("Become a Covid Watcher and help your community stay safe.", comment: "")
        let url = URL(string: "https://www.covid-watch.org")
        
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
}
