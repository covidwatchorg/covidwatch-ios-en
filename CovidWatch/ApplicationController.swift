//
//  Created by Zsombor Szabo on 04/05/2020.
//

import Foundation
import UIKit
import Combine
import ExposureNotification
import CommonCrypto
import SwiftUI
import ZIPFoundation

class ApplicationController: NSObject {
    
    static let shared = ApplicationController()
    
    var userNotificationsObserver: NSObjectProtocol?
    var exposureNotificationEnabledObservation: NSKeyValueObservation? = nil
    var exposureNotificationStatusObservation: NSKeyValueObservation? = nil
    
    override init() {
        super.init()
        
        if UserData.shared.firstRun {
            UserData.shared.firstRun = false
        }
        
        self.configureExposureNotificationStatusObserver()
        self.configureExposureNotificationEnabledObserver()
        self.configureUserNotificationStatusObserver()
    }
    
    func configureExposureNotificationStatusObserver() {
        self.exposureNotificationStatusObservation = ExposureManager.shared.manager.observe(
            \.exposureNotificationStatus, options: [.initial, .new]
        ) { (_, change) in
            
            DispatchQueue.main.async {
                withAnimation {
                    if self.checkENManagerAuthorizationStatus() {
                        UserData.shared.exposureNotificationStatus = ExposureManager.shared.manager.exposureNotificationStatus
                    }
                }
            }
        }
    }
    
    func configureExposureNotificationEnabledObserver() {
        self.exposureNotificationEnabledObservation = ExposureManager.shared.manager.observe(
            \.exposureNotificationEnabled, options: [.initial, .new]
        ) { (_, change) in
            
            DispatchQueue.main.async {
                withAnimation {
                    if self.checkENManagerAuthorizationStatus() {
                        UserData.shared.exposureNotificationEnabled =
                            ExposureManager.shared.manager.exposureNotificationEnabled
                    }
                }
            }
        }
    }
    
    func checkENManagerAuthorizationStatus() -> Bool {
        switch ENManager.authorizationStatus {
            case .restricted:
                UserData.shared.exposureNotificationStatus = .restricted
                UserData.shared.exposureNotificationEnabled = false
                return false
            case .notAuthorized:
                UserData.shared.exposureNotificationStatus = .disabled
                UserData.shared.exposureNotificationEnabled = false
                return false
            default:
             ()
        }
        return true
    }
    
    func configureUserNotificationStatusObserver() {
        self.userNotificationsObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            
            self?.checkNotificationPersmission()
        }
    }
    
    func checkNotificationPersmission() {
        UNUserNotificationCenter.current().getNotificationSettings(
            completionHandler: { (settings) in
                
                DispatchQueue.main.async {
                    withAnimation {
                        UserData.shared.notificationsAuthorizationStatus =
                            settings.authorizationStatus
                    }
                }
        })
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) else {
                return
        }
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
    
    func handleExposureNotificationEnabled(error: Error) {
        let nsError = error as NSError
        if nsError.domain == ENErrorDomain, nsError.code == ENError.notAuthorized.rawValue {
            let alertController = UIAlertController(
                title: NSLocalizedString("ERROR", comment: ""),
                message: NSLocalizedString("ACCES_TO_EN_DENIED", comment: "Error"),
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("CANCEL", comment: ""),
                style: .cancel,
                handler: nil)
            )
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("SETTINGS", comment: ""),
                style: .default,
                handler: { (action) in
                    ApplicationController.shared.openSettings()
                })
            )
            UIApplication.shared.topViewController?.present(alertController, animated: true)
        }
        else {
            UIApplication.shared.topViewController?.present(
                error,
                animated: true,
                completion: nil
            )
        }
    }
    
    @objc func shareApp() {
        let text = NSLocalizedString("Become a Covid Watcher and help your community stay safe.", comment: "")
        let url = URL(string: "https://www.covid-watch.org")
        
        let itemsToShare: [Any] = [text, url as Any]
        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        
        // so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView =
            UIApplication.shared.topViewController?.view
        
        // present the view controller
        UIApplication.shared.topViewController?.present(
            activityViewController,
            animated: true,
            completion: nil
        )
    }
    
    func handleTapShareAPositiveDiagnosisButton() {
        
        ExposureManager.shared.manager.getTestDiagnosisKeys { (keys, error) in
        //ExposureManager.shared.manager.getDiagnosisKeys { (keys, error) in
            if let error = error {
                UIApplication.shared.topViewController?.present(
                    error,
                    animated: true,
                    completion: nil
                )
                return
            }
            
            guard let keys = keys, !keys.isEmpty else {
                UIApplication.shared.topViewController?.present(
                    ENError(.internal),
                    animated: true,
                    completion: nil
                )
                return
            }
            
            let alertController = UIAlertController(
                title: String.localizedStringWithFormat(NSLocalizedString("Set transmission risk level for your %d TEK(s)", comment: ""), keys.count),
//                message: String.localizedStringWithFormat(NSLocalizedString("%d space-separated values of\n%@\nNote: The values can be different.", comment: ""), keys.count, (0...7).map({ ENRiskLevel($0).localizedTransmissionRiskLevelDescription}).joined(separator: "\n")),
                message: String.localizedStringWithFormat(NSLocalizedString("%d space-separated values between 0 and 7 inclusive\nNote: The values can be different.", comment: ""), keys.count),
                preferredStyle: .alert
            )
            alertController.addTextField { (textField) in
                textField.text = (0..<keys.count).map({ _ in "6" }).joined(separator: " ")
            }
            alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("CONTINUE", comment: ""), style: .default, handler: { _ in
                guard let text = alertController.textFields?.first?.text else { return }
                let stringValues = text.components(separatedBy: " ")
                guard stringValues.count == keys.count else { return }
                let values: [UInt8] = stringValues.compactMap({ UInt8($0) })
                self.handleTapContinueTransmissionRiskLevels(values, diagnosisKeys: keys)
            }))
            UIApplication.shared.topViewController?.present(alertController, animated: true)
        }
    }
    
    func handleTapContinueTransmissionRiskLevels(_ transmissionRiskLevels: [UInt8], diagnosisKeys: [ENTemporaryExposureKey]) {
        guard transmissionRiskLevels.count == diagnosisKeys.count else { return }
        let actionSheet = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("Share your %d TEK(s) with", comment: ""), diagnosisKeys.count), message: NSLocalizedString("Note: The TEK for the current day won't be shared with the server. When sharing with the server, you can set the transmission risk level only at the first upload.", comment: ""), preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Covid Watch Server", comment: ""), style: .default, handler: { [weak self] _ in
            self?.handleTapServer(diagnosisKeys: diagnosisKeys, transmissionRiskLevels: transmissionRiskLevels)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Other...", comment: ""), style: .default, handler: { [weak self] _ in
            self?.handleTapOther(diagnosisKeys: diagnosisKeys, transmissionRiskLevels: transmissionRiskLevels)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
        UIApplication.shared.topViewController?.present(actionSheet, animated: true)
    }
    
    func handleTapServer(diagnosisKeys: [ENTemporaryExposureKey], transmissionRiskLevels: [UInt8]) {
        guard transmissionRiskLevels.count == diagnosisKeys.count else { return }
        for index in 0..<diagnosisKeys.count {
            diagnosisKeys[index].transmissionRiskLevel = transmissionRiskLevels[index]
        }
        
        Server.shared.postDiagnosisKeys(Array(diagnosisKeys.dropFirst())) { error in
            if let error = error {
                UIApplication.shared.topViewController?.present(
                    error,
                    animated: true,
                    completion: nil
                )
                return
            }
        }
    }
    
    static let privateKeyECData = Data(base64Encoded: """
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgKJNe9P8hzcbVkoOYM4hJFkLERNKvtC8B40Y/BNpfxMeh\
    RANCAASfuKEs4Z9gHY23AtuMv1PvDcp4Uiz6lTbA/p77if0yO2nXBL7th8TUbdHOsUridfBZ09JqNQYKtaU9BalkyodM
    """)!
    
    func handleTapOther(diagnosisKeys: [ENTemporaryExposureKey], transmissionRiskLevels: [UInt8]) {
        guard transmissionRiskLevels.count == diagnosisKeys.count else { return }
        for index in 0..<diagnosisKeys.count {
            diagnosisKeys[index].transmissionRiskLevel = transmissionRiskLevels[index]
        }
        
        do {
            let attributes = [
                kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits: 256
            ] as CFDictionary
            
            var cfError: Unmanaged<CFError>? = nil
            
            let privateKeyData = ApplicationController.privateKeyECData.suffix(65) + ApplicationController.privateKeyECData.subdata(in: 36..<68)
            guard let secKey = SecKeyCreateWithData(privateKeyData as CFData, attributes, &cfError) else {
                throw cfError!.takeRetainedValue()
            }
            
            let signatureInfo = SignatureInfo.with { signatureInfo in
                signatureInfo.appBundleID = Bundle.main.bundleIdentifier!
                signatureInfo.verificationKeyVersion = "v1"
                signatureInfo.verificationKeyID = "310"
                signatureInfo.signatureAlgorithm = "SHA256withECDSA"
            }
            
            // In a real implementation, the file at remoteURL would be downloaded from a server
            // This sample generates and saves a binary and signature pair of files based on the locally stored diagnosis keys
            let export = TemporaryExposureKeyExport.with { export in
                export.batchNum = 1
                export.batchSize = 1
                export.region = "310"
                export.signatureInfos = [signatureInfo]
                export.keys = diagnosisKeys.shuffled().map { diagnosisKey in
                    TemporaryExposureKey.with { temporaryExposureKey in
                        temporaryExposureKey.keyData = diagnosisKey.keyData
                        temporaryExposureKey.transmissionRiskLevel = Int32(diagnosisKey.transmissionRiskLevel)
                        temporaryExposureKey.rollingStartIntervalNumber = Int32(diagnosisKey.rollingStartNumber)
                        temporaryExposureKey.rollingPeriod = Int32(diagnosisKey.rollingPeriod)
                    }
                }
            }
            
            let exportData = "EK Export v1    ".data(using: .utf8)! + (try export.serializedData())
            
            var exportHash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = exportData.withUnsafeBytes { exportDataBuffer in
                exportHash.withUnsafeMutableBytes { exportHashBuffer in
                    CC_SHA256(exportDataBuffer.baseAddress, CC_LONG(exportDataBuffer.count), exportHashBuffer.bindMemory(to: UInt8.self).baseAddress)
                }
            }
            
            guard let signedHash = SecKeyCreateSignature(secKey, .ecdsaSignatureDigestX962SHA256, exportHash as CFData, &cfError) as Data? else {
                throw cfError!.takeRetainedValue()
            }
            
            let tekSignatureList = TEKSignatureList.with { tekSignatureList in
                tekSignatureList.signatures = [TEKSignature.with { tekSignature in
                    tekSignature.signatureInfo = signatureInfo
                    tekSignature.signature = signedHash
                    tekSignature.batchNum = 1
                    tekSignature.batchSize = 1
                }]
            }
            
            let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            
            let localBinURL = cachesDirectory.appendingPathComponent("export.bin")
            try exportData.write(to: localBinURL)

            let localSigURL = cachesDirectory.appendingPathComponent("export.sig")
            try tekSignatureList.serializedData().write(to: localSigURL)

            let fileName = "\(UIDevice.current.name)_\(ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withInternetDateTime]))"
            
            var destinationURL = URL(fileURLWithPath: cachesDirectory.path)
            destinationURL.appendPathComponent("\(fileName).zip")
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            guard let archive = Archive(url: destinationURL, accessMode: .create) else  {
                return
            }
            try archive.addEntry(with: localBinURL.lastPathComponent, relativeTo: localBinURL.deletingLastPathComponent())
            try archive.addEntry(with: localSigURL.lastPathComponent, relativeTo: localSigURL.deletingLastPathComponent())
            
            let activityViewController = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
            activityViewController.setValue(fileName, forKey: "Subject")
            
            UIApplication.shared.topViewController?.present(
                activityViewController,
                animated: true,
                completion: nil
            )
        } catch {
            UIApplication.shared.topViewController?.present(error as NSError, animated: true)
        }
    }
    
    func exportExposures() {
        let alertController = UIAlertController(
            title: NSLocalizedString("Export Possible Exposures for Test Case", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { (textField) in
            textField.text = ""
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CONTINUE", comment: ""), style: .default, handler: { _ in
            guard let text = alertController.textFields?.first?.text else { return }
            self.exportExposures(forTestCase: text)
        }))
        UIApplication.shared.topViewController?.present(alertController, animated: true)
    }
    
    func exportExposures(forTestCase testCase: String) {        
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = "\(UIDevice.current.name)_\(ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withInternetDateTime]))_\(testCase)"
        let possibleExposuresPath = cachesDirectory.appendingPathComponent("\(fileName).json")
        do {
            let json = try JSONEncoder().encode(
                ExposureConfigurationWithExposures(
                    exposureConfiguration: LocalStore.shared.exposureConfiguration,
                    possibleExposures: LocalStore.shared.exposures
                )
            )
            try json.write(to: possibleExposuresPath)
            let activityViewController = UIActivityViewController(activityItems: [possibleExposuresPath], applicationActivities: nil)
            activityViewController.setValue(fileName, forKey: "Subject")
            UIApplication.shared.topViewController?.present(
                activityViewController,
                animated: true,
                completion: nil
            )
        } catch {
            UIApplication.shared.topViewController?.present(
                error as NSError,
                animated: true,
                completion: nil
            )
        }
    }
}
