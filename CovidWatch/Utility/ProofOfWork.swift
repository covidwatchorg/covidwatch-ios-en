//
//  ProofOfWork.swift
//  CovidWatch
//
//  Created by Madhava Jay on 15/5/20.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import CatCrypto

public struct PoWSolution: Equatable {
    let challengeNonceHex: String
    let workFactor: Int
    let solutionNonceHex: String
}

public struct PoWError: LocalizedError {
    var title: String?
    var code: Int
}

public struct ProofOfWork {
    let loopFactor = 16
    let challengeNonceHex: String
    let workFactor: Int

    init(challengeNonceHex: String, workFactor: Int) {
        self.challengeNonceHex = challengeNonceHex
        self.workFactor = workFactor
    }

    var context: CatArgon2Context {
        let context = CatArgon2Context()
        context.mode = .argon2id
        context.iterations = 1
        context.parallelism = 1
        context.memory = workFactor
        context.hashLength = 8
        context.hashResultType = .hashRaw
        context.saltBytes = [UInt8](hex: challengeNonceHex)
        return context
    }

    func solve() -> Result<PoWSolution, PoWError> {
        let argon = CatArgon2Crypto(context: self.context)
        for i in 0..<(self.workFactor*self.loopFactor) {
            let password = String(format: "%032d", i) // this is a unique attempt
            let passwordBytes = [UInt8](hex: password)
            let answer = argon.hash(passwordBytes: passwordBytes)

            if let hashBytes = answer.raw as? [UInt8] {
                let data = Data(hashBytes)
                if let uint64 = data.to(type: UInt64.self) {
                    let bigIndian = uint64.bigEndian
                    let valid = bigIndian % UInt64(self.workFactor) == 0
                    if valid {
                        return .success(
                            PoWSolution(
                                challengeNonceHex: self.challengeNonceHex,
                                workFactor: self.workFactor,
                                solutionNonceHex: password
                            )
                        )
                    }
                }
            }
        }

        return .failure(
            PoWError(
                title: "Failed to find a solution to \(self.challengeNonceHex)",
                code: 1
            )
        )
    }
}

extension Data {
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)})
        return value
    }
}

//extension String {
//
//    /// Decode string with desire mode.
//    ///
//    /// - Parameter encodeMode: Mode for Decode.
//    /// - Returns: Bytes.
//    func decode(encodeMode: EncodeMode = .hex) -> [UInt8] {
//        switch encodeMode {
//        case .hex: return self.hexDecode()
//        case .base64: return self.base64Decode()
//        }
//    }
//
//    /// Decode hexadecimal string to bytes.
//    ///
//    /// - Returns: Decoded bytes.
//    func hexDecode() -> [UInt8] {
//        var start = startIndex
//        return (0...count/2).compactMap {  _ in
//            let end = index(start, offsetBy: 2, limitedBy: endIndex) ?? endIndex
//            defer { start = end }
//            return UInt8(String(self[start..<end]), radix: 16)
//        }
//    }
//
//    /// Decode base64 string to bytes.
//    ///
//    /// - Returns: Decoded bytes.
//    func base64Decode() -> [UInt8] {
//        let base64Data = Data(base64Encoded: self)
//        let decodeString = String(data: base64Data ?? Data(), encoding: String.Encoding.utf8) ?? ""
//        return [UInt8](decodeString.utf8)
//    }
//
//    /// Generate an appoint length string fill by zero.
//    ///
//    /// - Parameter length: Zero count.
//    /// - Returns: Desired zero string.
//    static func zeroString(length: Int) -> String {
//        var zeroString = String()
//        for _ in 0 ..< length {
//            zeroString += "0"
//        }
//        return zeroString
//    }
//
//}
//
///// Encode modes.
//public enum EncodeMode {
//
//    /// Hexadecimal.
//    case hex
//
//    /// Base64.
//    case base64
//
//}
//
//extension Array {
//
//    /// Encode bytes with desire mode.
//    ///
//    /// - Parameter encodeMode: Mode for encode.
//    /// - Returns: Encoded string.
//    func encode(encodeMode: EncodeMode = .hex) -> String {
//        if self is [UInt8] {
//            switch encodeMode {
//            case .hex: return self.hexEncode()
//            case .base64: return self.base64Encode()
//            }
//        }
//        return ""
//    }
//
//    /// Encode to hexadecimal string.
//    ///
//    /// - Returns: Encoded string.
//    func hexEncode() -> String {
//        var hexString = String()
//        for element in self {
//            hexString = hexString.appendingFormat("%02x", (element as? UInt8)!)
//        }
//        return hexString
//    }
//
//    /// Encode to base64 string.
//    ///
//    /// - Returns: Encoded string.
//    func base64Encode() -> String {
//        let base64Data = Data(bytes: self, count: self.count)
//        return base64Data.base64EncodedString()
//    }
//
//}
