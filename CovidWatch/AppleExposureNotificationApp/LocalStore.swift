/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that contains and manages locally stored app data.
*/

import Foundation
import ExposureNotification

public struct Exposure: Codable {
    public let date: Date
    public let duration: TimeInterval
    public let totalRiskScore: ENRiskScore
    public let transmissionRiskLevel: ENRiskLevel
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
    public var isOnboarded: Bool
    
    @Persisted(userDefaultsKey: "nextDiagnosisKeyFileIndex", notificationName: .init("LocalStoreNextDiagnosisKeyFileIndexDidChange"), defaultValue: 0)
    public var nextDiagnosisKeyFileIndex: Int
    
    @Persisted(userDefaultsKey: "exposures", notificationName: .init("LocalStoreExposuresDidChange"), defaultValue: [])
    public var exposures: [Exposure]
    
    @Persisted(userDefaultsKey: "dateLastPerformedExposureDetection",
               notificationName: .init("LocalStoreDateLastPerformedExposureDetectionDidChange"), defaultValue: nil)
    public var dateLastPerformedExposureDetection: Date?
    
    @Persisted(userDefaultsKey: "exposureDetectionErrorLocalizedDescription", notificationName:
        .init("LocalStoreExposureDetectionErrorLocalizedDescriptionDidChange"), defaultValue: nil)
    public var exposureDetectionErrorLocalizedDescription: String?
    
    @Persisted(userDefaultsKey: "testResults", notificationName: .init("LocalStoreTestResultsDidChange"), defaultValue: [])
    public var testResults: [TestResult]
    
}
