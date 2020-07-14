/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that contains and manages locally stored app data.
*/

import Foundation
import ExposureNotification

public struct Exposure: Codable, Equatable {
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

public struct Diagnosis: Codable {
    public var id = UUID()                // A unique identifier for this test result used internally
    public var isAdded = false            // Whether the user completed the add diagnosis flow for this test result
    public var testDate = Date()  // The date the test was administered
    public var isShared = false           // Whether diagnosis keys were shared with the Health Authority for the purpose of notifying others
    public var symptomsStartDate: Date?
    public var isVerified = false         // Whether the diagnosis was verified by the Health Authority for the purpose of notifying others
    public var verificationCode: String?  // The 8-digit verification code issued by the Verification Server
    public var longTermToken: String?     // The 24h long-term token issued by the Verification Server
    public var testType: String          // The test type. Can be `confirmed`, `negative`, `likely`
    public var hmacKey: Data = Data.random(count: 16) // The secret key used for hmac calculation of the diagnosis keys
    public var verificationCertificate: String? // The verification certificate issued by the Verification Server
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

    @Persisted(userDefaultsKey: "isOnboarded", notificationName: .init("LocalStoreIsOnboardedDidChange"), defaultValue: false)
    public var isOnboarded: Bool {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "previousDiagnosisKeyFileURLs", notificationName: .init("LocalStorePreviousDiagnosisKeyFileURLsDidChange"), defaultValue: [])
    public var previousDiagnosisKeyFileURLs: [URL] {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "exposures", notificationName: .init("LocalStoreExposuresDidChange"), defaultValue: [])
    public var exposures: [Exposure] {
        willSet { objectWillChange.send() }
    }

    @Persisted(userDefaultsKey: "riskLevelValue", notificationName: .init("LocalStoreRiskLevelValueDidChange"), defaultValue: nil)
    public var riskLevelValue: Float? {
        willSet { objectWillChange.send() }
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
    }

    #if DEBUG_CALIBRATION
    static let exposureConfigurationDefault: String =
    """
    {"minimumRiskScore":0,
    "attenuationDurationThresholdList":[[30,33],[33,36],[36,39],[39,42],[42,45],[45,48],[48,51],[51,54],[54,57],[57,60],[60,63],[63,66],[66,69],[69,72],[72,75],[75,78],[78,81],[81,84],[84,87],[87,90],[90,93],[93,96],[96,99]],
    "attenuationDurationThresholds":[50, 58],
    "attenuationLevelValues":[8, 7, 6, 5, 4, 3, 2, 1],
    "daysSinceLastExposureLevelValues":[1, 1, 1, 1, 1, 1, 1, 1],
    "durationLevelValues":[0, 1, 2, 3, 4, 5, 6, 7],
    "transmissionRiskLevelValues":[1, 1, 1, 1, 1, 1, 1, 1]}
    """
    #else
    // Data from: https://developer.apple.com/documentation/exposurenotification/enexposureconfiguration
    static let exposureConfigurationDefault: String =
    """
    {"minimumRiskScore":0,
    "attenuationDurationThresholds":[50, 70],
    "attenuationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
    "daysSinceLastExposureLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
    "durationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
    "transmissionRiskLevelValues":[1, 2, 3, 4, 5, 6, 7, 8]}
    """
    #endif

    @Persisted(userDefaultsKey: "exposureConfiguration", notificationName: .init("LocalStoreExposureConfigurationDidChange"), defaultValue:exposureConfigurationDefault)
    public var exposureConfiguration: String {
        willSet { objectWillChange.send() }
    }

}
