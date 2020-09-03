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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Setup window
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.window?.tintColor = UIColor(named: "Tint Color")
        window.makeKeyAndVisible()
        let contentView = ContentView().environmentObject(LocalStore.shared)
        self.window?.rootViewController = UIHostingController(rootView: contentView)

        // Setup exposure notification key and verification servers
        Server.shared.keyServer = GoogleExposureNotificationsDiagnosisKeyServer(configuration: .shared)
        Server.shared.verificationServer = GoogleExposureNotificationsDiagnosisVerificationServer(configuration: .shared)

        // Setup exposure notification manager
        _ = ExposureManager.shared
        let useAZRiskModel = Bundle.main.infoDictionary?[.useAZRiskModel] as? Bool ?? false
        if useAZRiskModel {
            let riskModel = AZExposureRiskModel(configuration: LocalStore.shared.region.azRiskModelConfiguration)
            ExposureManager.shared.riskModel = riskModel
        }

        // Setup application controller
        _ = ApplicationController.shared
        ApplicationController.shared.refreshRegions()
//        ApplicationController.shared.defaultRegionJSON()
//        LocalStore.shared.exposuresInfos = [CodableExposureInfo(attenuationDurations: [30, 30, 30], attenuationValue: 1, date: Date(), duration: 30, totalRiskScore: 6, transmissionRiskLevel: 6)]

        // Setup background tasks
        self.setupBackgroundTask()

        // Setup user notifications
        self.configureCurrentUserNotificationCenter()
        self.requestUserNotificationAuthorization(provisional: true)

        return true
    }

}
