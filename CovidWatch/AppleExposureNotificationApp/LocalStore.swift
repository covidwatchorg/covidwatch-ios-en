/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that contains and manages locally stored app data.
*/

import Foundation
import ExposureNotification

public struct Exposure: Codable {
    let attenuationDurations: [TimeInterval]
    let attenuationValue: ENAttenuation
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let totalRiskScoreFullRange: Int
    let transmissionRiskLevel: ENRiskLevel
    let attenuationDurationThresholds: [Int]
    let timeDetected: Date
}

public struct TestResult: Codable {
    public var id: UUID                // A unique identifier for this test result
    public var isAdded: Bool           // Whether the user completed the add positive diagnosis flow for this test result
    public var dateAdministered: Date  // The date the test was administered
    public var isShared: Bool          // Whether diagnosis keys were shared with the Health Authority for the purpose of notifying others
    public var verificationCode: String
    public var isVerified: Bool
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
            UserDefaults.standard.set(try! JSONEncoder().encode(wrappedValue), forKey: userDefaultsKey)
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
    
    @Persisted(userDefaultsKey: "nextDiagnosisKeyFileIndex", notificationName: .init("LocalStoreNextDiagnosisKeyFileIndexDidChange"), defaultValue: 0)
    public var nextDiagnosisKeyFileIndex: Int {
        willSet { objectWillChange.send() }
    }
    
    @Persisted(userDefaultsKey: "exposures", notificationName: .init("LocalStoreExposuresDidChange"), defaultValue: [])
    public var exposures: [Exposure] {
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
    
    @Persisted(userDefaultsKey: "testResults", notificationName: .init("LocalStoreTestResultsDidChange"), defaultValue: [])
    public var testResults: [TestResult] {
        willSet { objectWillChange.send() }
    }
    
    // Data from: https://developer.apple.com/documentation/exposurenotification/enexposureconfiguration
    static let exposureConfigurationDefault: String =
    """
    {"minimumRiskScore":0,
    "attenuationDurationThresholdList":[[40,42],[42,44],[44,46],[46,48],[48,50],[50,52], [52,54],[54,56], [56,58],[58,60], [60,63],[63,67], [67,72], [72,80]],
    "attenuationDurationThresholds":[50, 58],
    "attenuationLevelValues":[2, 5, 8, 8, 8, 8, 8, 8],
    "daysSinceLastExposureLevelValues":[1, 2, 2, 4, 6, 8, 8, 8],
    "durationLevelValues":[1, 1, 4, 7, 7, 8, 8, 8],
    "transmissionRiskLevelValues":[0, 3, 6, 8, 8, 6, 0, 6]}
    """
//    """
//    {"minimumRiskScore":0,
//    "attenuationDurationThresholds":[50, 70],
//    "attenuationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
//    "daysSinceLastExposureLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
//    "durationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
//    "transmissionRiskLevelValues":[1, 2, 3, 4, 5, 6, 7, 8]}
//    """
    
        //"attenuationDurationThresholdList":[[40,42],[44,46], [48,50], [52,54], [56,58], [60,62], [64,66], [68,70]],
    
    @Persisted(userDefaultsKey: "exposureConfiguration", notificationName: .init("LocalStoreExposureConfigurationDidChange"), defaultValue:exposureConfigurationDefault)
    public var exposureConfiguration: String {
        willSet { objectWillChange.send() }
    }
    
}
