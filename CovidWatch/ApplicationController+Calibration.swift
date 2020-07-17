//
//  Created by Zsombor Szabo on 24/06/2020.
//  
//

import Foundation
import UIKit
import Combine
import ExposureNotification
import CommonCrypto
import SwiftUI
import ZIPFoundation

#if DEBUG_CALIBRATION
extension ApplicationController {

    public func handleTapCalibrationShareAPositiveDiagnosisButton() {
        ExposureManager.shared.getDiagnosisKeys { (keys, error) in
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

        Server.shared.postDiagnosisKeys(diagnosisKeys) { error in
            if let error = error {
                DispatchQueue.main.async {
                    UIApplication.shared.topViewController?.present(
                        error,
                        animated: true,
                        completion: nil
                    )
                }
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

            var cfError: Unmanaged<CFError>?

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
            guard let archive = Archive(url: destinationURL, accessMode: .create) else {
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

}
#endif
