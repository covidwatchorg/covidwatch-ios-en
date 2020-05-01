//
//  Created by Zsombor Szabo on 26/04/2020.
//

import UIKit
import CoreData
import ExposureNotification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var isFetching = false
    var fetchCompletionHandlers = [((Result<Void, Error>) -> Void)]()
    
    var diagnosisServer = CovidWatchDiagnosisServer()
    //    var diagnosisServer = MockDiagnosisServer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor = UIColor(named: "tintColor")

        print("Starting app with: \(getAppScheme()) and API Url: \(getAPIUrl(getAppScheme()))")

        // Setup Exposure Notification
        let exposureInfoTableViewController = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? ExposureInfoTableViewController
        exposureInfoTableViewController?.diagnosisServer = diagnosisServer
        ENManager.shared.activate { (error) in
            if let error = error {
                UIApplication.shared.topViewController?.present(error as NSError, animated: true, completion: nil)
            }
        }
        
        self.registerBackgroundTasks()
        
        let actionsAfterLoading = {
            UserDefaults.standard.register(defaults: UserDefaults.Key.registration)
            PersistentContainer.shared.loadInitialData()
            self.configureCurrentUserNotificationCenter()
            self.requestUserNotificationAuthorization(provisional: true)
        }
        PersistentContainer.shared.load { error in
            if let error = error {
                let alertController = UIAlertController(title: NSLocalizedString("Error Loading Data", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete Data", comment: ""), style: .destructive, handler: { _ in
                    let confirmDeleteController = UIAlertController(title: NSLocalizedString("Confirm", comment: ""), message: nil, preferredStyle: .alert)
                    confirmDeleteController.addAction(UIAlertAction(title: NSLocalizedString("Delete Data", comment: ""), style: .destructive, handler: { _ in
                        PersistentContainer.shared.delete()
                        abort()
                    }))
                    confirmDeleteController.addAction(UIAlertAction(title: NSLocalizedString("Quit", comment: ""), style: .cancel, handler: { _ in
                        abort()
                    }))
                    UIApplication.shared.topViewController?.present(confirmDeleteController, animated: true, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Quit", comment: ""), style: .cancel, handler: { _ in
                    abort()
                }))
                UIApplication.shared.topViewController?.present(alertController, animated: true, completion: nil)
                return
            }
            actionsAfterLoading()
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        PersistentContainer.shared.load { (error) in
            guard error == nil else { return }
            if ENManager.shared.exposureNotificationEnabled {
                self.performFetch(task: nil, completionHandler: nil)
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save changes in the application's managed object context when the application transitions to the background.
        if PersistentContainer.shared.isLoaded {
            PersistentContainer.shared.saveContext()
        }
        self.scheduleBackgroundTasks()
    }
}
