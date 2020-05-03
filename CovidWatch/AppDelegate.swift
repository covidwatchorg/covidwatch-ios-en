//
//  Created by Zsombor Szabo on 26/04/2020.
//

import UIKit
import CoreData
import ExposureNotification
import CovidWatchExposureNotification
import os.log
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Background tasks
    var isPerformingFetch = false
    
    // Diagnosis server
    var diagnosisServer = CovidWatchDiagnosisServer(
        apiUrlString: getAPIUrl(getAppScheme())
    )
    //    var diagnosisServer = MockDiagnosisServer()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        os_log(
            "Starting app with scheme=%@ and API Url=%@",
            log: .app,
            getAppScheme().description,
            getAPIUrl(getAppScheme())
        )
                
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.window?.tintColor = UIColor(named: "tintColor")
        window.makeKeyAndVisible()
        
        // Setup Exposure Notification
//        let exposureInfoTableViewController = (window?.rootViewController as?
//            UINavigationController)?.viewControllers.first as? ExposureInfoTableViewController
//        exposureInfoTableViewController?.diagnosisServer = diagnosisServer
        
        ENManager.shared.activate { (error) in
            if let error = error {
                UIApplication.shared.topViewController?.present(
                    error as NSError,
                    animated: true,
                    completion: nil
                )
            }
        }
        
        // Setup Background tasks
        self.registerBackgroundTasks()
        
        // Setup User notification
        self.configureCurrentUserNotificationCenter()
        self.requestUserNotificationAuthorization(provisional: true)
        
        // Setup Core Data
        PersistentContainer.shared.load { error in
            if let error = error {
                let alertController = UIAlertController(
                    title: NSLocalizedString("Error Loading Data", comment: ""),
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString("Delete Data", comment: ""),
                    style: .destructive,
                    handler: { _ in
                        
                        let confirmDeleteController = UIAlertController(
                            title: NSLocalizedString("Confirm", comment: ""),
                            message: nil, preferredStyle: .alert
                        )
                        confirmDeleteController.addAction(UIAlertAction(
                            title: NSLocalizedString("Delete Data", comment: ""),
                            style: .destructive,
                            handler: { _ in
                                PersistentContainer.shared.delete()
                                abort()
                        }))
                        confirmDeleteController.addAction(UIAlertAction(
                            title: NSLocalizedString("Quit", comment: ""),
                            style: .cancel,
                            handler: { _ in
                                abort()
                        }))
                        UIApplication.shared.topViewController?.present(
                            confirmDeleteController,
                            animated: true,
                            completion: nil
                        )
                }))
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString("Quit", comment: ""),
                    style: .cancel,
                    handler: { _ in
                        abort()
                }))
                UIApplication.shared.topViewController?.present(
                    alertController,
                    animated: true,
                    completion: nil
                )
                return
            }
            
            let contentView = ContentView().environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
            self.window?.rootViewController = UIHostingController(rootView: contentView)
            
            // Load mock data
            PersistentContainer.shared.loadInitialData()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if PersistentContainer.shared.isLoaded &&
            ENManager.shared.exposureNotificationEnabled {
            self.performFetch(withTask: nil)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save changes in the application's managed object context when the
        // application transitions to the background.
        if PersistentContainer.shared.isLoaded {
            PersistentContainer.shared.saveContext()
        }
        self.scheduleBackgroundTasks()
    }
}
