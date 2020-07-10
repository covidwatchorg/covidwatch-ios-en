//
//  Created by Zsombor Szabo on 02/07/2020.
//  
//

import Foundation
import UIKit
import os.log

#if DEBUG_CALIBRATION
extension AppDelegate {

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {

        do {
            guard let cachesDirectoryURL = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first else {
                throw(CocoaError(.fileNoSuchFile))
            }
            let unzipDestinationDirectory = cachesDirectoryURL.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(
                at: unzipDestinationDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try FileManager.default.unzipItem(at: url, to: unzipDestinationDirectory)
            try FileManager.default.removeItem(at: url)
            let zipFileContentURLs = try FileManager.default.contentsOfDirectory(
                at: unzipDestinationDirectory,
                includingPropertiesForKeys: nil
            )
            let filteredZIPFileContentURLs = zipFileContentURLs.filter { (url) -> Bool in
                let size: UInt64 = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? UInt64) ?? 0
                return size != 0
            }
            let result = filteredZIPFileContentURLs

            _ = ExposureManager.shared.detectExposures(importURLs: result, notifyUserOnError: true) { success in
                os_log(
                    "Detected exposures from file=%@ success=%d",
                    log: .app,
                    url.description,
                    success
                )
            }
        } catch {
            UIApplication.shared.topViewController?.present(
                error as NSError,
                animated: true
            )
        }

        return true
    }

}
#endif
