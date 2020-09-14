/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that contains and manages locally stored app data.
*/

import Foundation
import ExposureNotification
import SwiftUI

public struct CodableExposureInfo: Codable, Equatable, Hashable {
    let attenuationDurations: [TimeInterval]
    let attenuationValue: ENAttenuation
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let transmissionRiskLevel: ENRiskLevel
    #if DEBUG_CALIBRATION
    let attenuationDurationThresholds: [Int]
    let timeDetected: Date
    #endif
}

public struct Diagnosis: Codable, Equatable {
    public var id = UUID()                // A unique identifier for this test result used internally
    public var isAdded = false            // Whether the user completed the add diagnosis flow for this test result
    public var submitDate: Date?
    public var isSubmitted = false { // Whether diagnosis keys were shared with the Health Authority for the purpose of notifying others
        didSet { self.submitDate = Date() }
    }
    public var testDate: Date?  // The date the test was administered
    public var symptomsStartDate: Date?
    public var possibleInfectionDate: Date?
    public var isVerified = false // Whether the diagnosis was verified by the Health Authority for the purpose of notifying others
    public var verificationCode: String?  // The 8-digit verification code issued by the Verification Server
    public var longTermToken: String?     // The 24h long-term token issued by the Verification Server
    public var testType: String          // The test type. Can be `confirmed`, `negative`, `likely`
    public var hmacKey: Data = Data.random(count: 16) // The secret key used for hmac calculation of the diagnosis keys
    public var verificationCertificate: String? // The verification certificate issued by the Verification Server
    public var shareZeroTranmissionRiskLevelDiagnosisKeys: Bool = false
}

@propertyWrapper
public class Persisted<Value: Codable> {

    init(userDefaultsKey: String, notificationName: Notification.Name, defaultValue: Value) {
        self.userDefaultsKey = userDefaultsKey
        self.notificationName = notificationName
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                wrappedValue = try JSONDecoder().decode(Value.self, from: data)
            } catch {
                wrappedValue = defaultValue
            }
        } else {
            wrappedValue = defaultValue
        }
    }

    let userDefaultsKey: String
    let notificationName: Notification.Name

    public var wrappedValue: Value {
        didSet {
            UserDefaults.standard.set(try? JSONEncoder().encode(wrappedValue), forKey: userDefaultsKey)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }

    public var projectedValue: Persisted<Value> { self }

    func addObserver(using block: @escaping () -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { _ in
            block()
        }
    }
}

public class LocalStore: ObservableObject {

    public static let shared = LocalStore()

    @Persisted(userDefaultsKey: "previousDiagnosisKeyFileURLs", notificationName: .init("LocalStorePreviousDiagnosisKeyFileURLsDidChange"), defaultValue: [])
    public var previousDiagnosisKeyFileURLs: [URL] {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "exposureInfos", notificationName: .init("LocalStoreExposureInfosDidChange"), defaultValue: [])
    public var exposuresInfos: [CodableExposureInfo] {
        willSet { objectWillChange.send() }
        didSet { ExposureManager.shared.updateRiskMetricsIfNeeded() }
    }

    @Persisted(userDefaultsKey: "dateLastPerformedExposureDetection",
               notificationName: .init("LocalStoreDateLastPerformedExposureDetectionDidChange"), defaultValue: nil)
    public var dateLastPerformedExposureDetection: Date? {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "exposureDetectionErrorLocalizedDescription", notificationName:
        .init("LocalStoreExposureDetectionErrorLocalizedDescriptionDidChange"), defaultValue: nil)
    public var exposureDetectionErrorLocalizedDescription: String? {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "diagnoses", notificationName: .init("LocalStoreDiagnosesDidChange"), defaultValue: [])
    public var diagnoses: [Diagnosis] {
        willSet { objectWillChange.send() }
        didSet { self.updateHomeRiskLevel() }
    }

    @Persisted(userDefaultsKey: "riskMetrics", notificationName: .init("LocalStoreRiskMetricsDidChange"), defaultValue: nil)
    public var riskMetrics: RiskMetrics? {
        willSet { objectWillChange.send() }
        didSet { self.updateHomeRiskLevel() }
    }

    @Persisted(userDefaultsKey: "homeRiskLevel", notificationName: .init("LocalStoreHomeRiskLevelDidChange"), defaultValue: .low)
    public var homeRiskLevel: HomeRiskLevel {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "regions", notificationName: .init("LocalStoreRegionsDidChange"), defaultValue: CodableRegion.all)
    public var regions: [CodableRegion] {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "region", notificationName: .init("LocalStoreRegionDidChange"), defaultValue: .default)
    public var region: CodableRegion {
        willSet { objectWillChange.send() }
        didSet {
            // Update risk model configuration from region
            if let azRiskModel = ExposureManager.shared.riskModel as? AZExposureRiskModel {
                azRiskModel.configuration = region.azRiskModelConfiguration
                ExposureManager.shared.updateRiskMetricsIfNeeded()
            }
        }
    }

    public var selectedRegionIndex: Int {
        self.regions.firstIndex(where: { $0.id == self.region.id }) ?? 0
    }

    // User Data

    @Published(key: "firstRun")
    var firstRun: Bool = true

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
