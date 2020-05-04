//
//  Created by Zsombor Szabo on 04/05/2020.
//

import Foundation
import UIKit
import Combine
import ExposureNotification
import CovidWatchExposureNotification
import SwiftUI

class ApplicationController: NSObject {
    
    static let shared = ApplicationController()
    
    let userData = UserData()
    
    var userNotificationsObserver: NSObjectProtocol?
    var exposureNotificationStatusObservation: NSKeyValueObservation? = nil
    
    override init() {
        super.init()
        
        if self.userData.firstRun {
            self.userData.firstRun = false
        }
        
        self.activeExposureNotification()
        self.configureExposureNotificationStatusObserver()
        self.configureUserNotificationStatusObserver()
    }
    
    func activeExposureNotification(notifyUserOnError: Bool = false) {
        
        ENManager.shared.activate { (error) in
            
            if let error = error {
                if notifyUserOnError {
                    UIApplication.shared.topViewController?.present(
                        error as NSError,
                        animated: true,
                        completion: nil
                    )
                }
                return
            }
        }
    }
    
    func startExposureNotification(notifyUserOnError: Bool = false) {
        
        ENManager.shared.setExposureNotificationEnabled(true) { (error) in
            
            if let error = error {
                if notifyUserOnError {
                    UIApplication.shared.topViewController?.present(
                        error as NSError,
                        animated: true,
                        completion: nil
                    )
                }
                return
            }
        }
    }
    
    func configureExposureNotificationStatusObserver() {
        self.exposureNotificationStatusObservation = ENManager.shared.observe(
            \.exposureNotificationStatus, options: [.initial, .old, .new]
        ) { [weak self] (_, change) in
            
            DispatchQueue.main.async {
                withAnimation {
                    self?.userData.exposureNotificationStatus =
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
            completionHandler: { [weak self] (settings) in
                
                DispatchQueue.main.async {
                    withAnimation {
                        self?.userData.notificationsAuthorizationStatus =
                            settings.authorizationStatus
                    }
                }
        })
    }
    
    @objc func share() {
        let text = "Become a Covid Watcher and help your community stay safe."
        let url = NSURL(string: "https://www.covid-watch.org")
        
        let itemsToShare: [Any] = [ text, url as Any ]
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
