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
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Access to Exposure Notification denied.", comment: ""),
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil)
            )
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Settings", comment: ""),
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
        
        ExposureManager.shared.manager.getDiagnosisKeys { (keys, error) in
            if let error = error {
                UIApplication.shared.topViewController?.present(
                    error,
                    animated: true,
                    completion: nil
                )
                return
            }
            
            let actionSheet = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("Choose transmission risk level for your %d TEK(s)", comment: ""), keys!.count), message: nil, preferredStyle: .actionSheet)
            for index in 0...8 {
                actionSheet.addAction(UIAlertAction(title: String(index), style: .default, handler: { [weak self] _ in
                    //self?.post(diagnosisKeys: keys!, transmissionRiskLevel: UInt8(index))
                    self?.handleTapTransmissionRiskLevel(UInt8(index), diagnosisKeys: keys!)
                }))
            }
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            UIApplication.shared.topViewController?.present(actionSheet, animated: true)
        }
    }
    
    func handleTapTransmissionRiskLevel(_ tranmissionRiskLevel: UInt8, diagnosisKeys: [ENTemporaryExposureKey]) {
        let actionSheet = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("Share your %d TEK(s) with transmission risk level=%d with", comment: ""), diagnosisKeys.count, tranmissionRiskLevel), message: NSLocalizedString("Important: The TEK for the current day won't be shared. When sharing with the server, you can set the transmission risk level only at the first upload.", comment: ""), preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Covid Watch Server", comment: ""), style: .default, handler: { [weak self] _ in
            self?.handleTapServer(diagnosisKeys: diagnosisKeys, transmissionRiskLevel: tranmissionRiskLevel)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Other...", comment: ""), style: .default, handler: { [weak self] _ in
            self?.handleTapOther(diagnosisKeys: diagnosisKeys, transmissionRiskLevel: tranmissionRiskLevel)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        UIApplication.shared.topViewController?.present(actionSheet, animated: true)
    }
    
    func handleTapServer(diagnosisKeys: [ENTemporaryExposureKey], transmissionRiskLevel: UInt8) {
        
        diagnosisKeys.forEach { $0.transmissionRiskLevel = transmissionRiskLevel }
        
        Server.shared.postDiagnosisKeys(diagnosisKeys) { error in
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
    
    func handleTapOther(diagnosisKeys: [ENTemporaryExposureKey], transmissionRiskLevel: UInt8) {
        
        diagnosisKeys.forEach { $0.transmissionRiskLevel = transmissionRiskLevel }
        
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

            var destinationURL = URL(fileURLWithPath: cachesDirectory.path)
            destinationURL.appendPathComponent("export.zip")
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            guard let archive = Archive(url: destinationURL, accessMode: .create) else  {
                return
            }
            try archive.addEntry(with: localBinURL.lastPathComponent, relativeTo: localBinURL.deletingLastPathComponent())
            try archive.addEntry(with: localSigURL.lastPathComponent, relativeTo: localSigURL.deletingLastPathComponent())
            
            let activityViewController = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
            
            UIApplication.shared.topViewController?.present(
                activityViewController,
                animated: true,
                completion: nil
            )
        } catch {
            UIApplication.shared.topViewController?.present(error as NSError, animated: true)
        }
    }
}
