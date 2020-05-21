//
//  Created by Zsombor Szabo on 26/04/2020.
//

import UIKit
import CoreData
import ExposureNotification

import os.log
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Background tasks
    var isPerformingBackgroundExposureNotification = false
    
    // Diagnosis server
    var diagnosisServer = CovidWatchDiagnosisServer(configuration: .current)
    
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
        self.window?.tintColor = UIColor(named: "Tint Color")
        window.makeKeyAndVisible()
        let contentView = ContentView()
            .environmentObject(UserData.shared)
            .environmentObject(LocalStore.shared)
        self.window?.rootViewController = UIHostingController(rootView: contentView)
        
        // Setup diagnosis server
        Server.shared.diagnosisServer = self.diagnosisServer
        
        _ = ExposureManager.shared
        _ = ApplicationController.shared
        
        // Setup Background tasks
        self.setupBackgroundTask()
        
        // Setup User notification
        self.configureCurrentUserNotificationCenter()
        self.requestUserNotificationAuthorization(provisional: true)
        
        return true
    }    
}
