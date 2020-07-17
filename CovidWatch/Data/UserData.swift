//
//  Created by Zsombor Szabo on 04/05/2020.
//
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import ExposureNotification

final class UserData: ObservableObject {

    public static let shared = UserData()

    @Published(key: "firstRun")
    var firstRun: Bool = true

    @Persisted(userDefaultsKey: "regions", notificationName: .init("UserDataRegionsDidChange"), defaultValue: CodableRegion.all)
    public var regions: [CodableRegion] {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "region", notificationName: .init("UserDataRegionDidChange"), defaultValue: CodableRegion.default)
    public var region: CodableRegion {
        willSet { objectWillChange.send() }
    }

    public var selectedRegionIndex: Int {
        CodableRegion.all.firstIndex(where: {
            $0.name == self.region.name
        }) ?? 0
    }

    @Published(key: "isOnboardingCompleted")
    var isOnboardingCompleted: Bool = false

    @Published(key: "isSetupCompleted")
    var isSetupCompleted: Bool = false

    @Published
    var showHomeWelcomeMessage: Bool = false

    @Published
    var exposureNotificationEnabled: Bool = ExposureManager.shared.manager.exposureNotificationEnabled {
        didSet {
            guard exposureNotificationEnabled != oldValue else { return }

            defer {
                self.configureExposureNotificationStatusMessage()
            }

            guard ENManager.authorizationStatus == .authorized else {
                if ENManager.authorizationStatus != .unknown {
                    if self.exposureNotificationEnabled {
                        withAnimation {
                            ApplicationController.shared.handleExposureNotificationEnabled(error: ENError(.notAuthorized))
                            self.exposureNotificationEnabled = false
                        }
                    }
                }
                return
            }

            ExposureManager.shared.manager.setExposureNotificationEnabled(
                self.exposureNotificationEnabled
            ) { (error) in

                if let error = error {
                    ApplicationController.shared.handleExposureNotificationEnabled(error: error)
                    return
                }
            }
        }
    }

    @Published
    var exposureNotificationStatus: ENStatus = .active {
        didSet {
            configureExposureNotificationStatusMessage()
        }
    }

    func configureExposureNotificationStatusMessage() {
        self.exposureNotificationStatusMessage =
            self.exposureNotificationStatus.localizedDetailDescription
    }

    @Published
    var exposureNotificationStatusMessage: String = ""

    @Published
    var notificationsAuthorizationStatus: UNAuthorizationStatus = .authorized
}
