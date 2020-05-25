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
    lazy var diagnosisServer: DiagnosisServer = {
        let appScheme = getAppScheme()
        switch appScheme {
            case .development:
                // TODO
                return GCPGoogleExposureNotificationServer(
                    exposureURLString: getAPIUrl(appScheme) + "/publish",
                    appConfiguration: AppConfiguration(regions: ["US"]),
                    exportConfiguration: ExportConfiguration(
                        filenameRoot: "exposureKeyExport-US",
                        bucketName: "exposure-notification-export-ibznj"
                    )
            )
            case .production:
                // This returns the configuration for the sandbox CW EN server
                return GCPGoogleExposureNotificationServer(
                    exposureURLString: "https://exposure-2sav64smma-uc.a.run.app/",
                    appConfiguration: AppConfiguration(regions: ["US"]),
                    exportConfiguration: ExportConfiguration(
                        filenameRoot: "exposureKeyExport-US",
                        bucketName: "exposure-notification-export-ibznj"
                    )
            )
        }
    }()
    
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
        
        // Testing: Detect exposures on app launch
        if ENManager.authorizationStatus == .authorized {
            _ = ExposureManager.shared.detectExposures { success in
                os_log(
                    "Detected exposures success=%d",
                    log: .app,
                    success
                )
            }
        }
        
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
