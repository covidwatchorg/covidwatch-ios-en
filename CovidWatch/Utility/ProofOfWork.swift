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
    let hashHex: String?

    init(challengeNonceHex: String, workFactor: Int,
         solutionNonceHex: String, hashHex: String? = nil) {
        self.challengeNonceHex = challengeNonceHex
        self.workFactor = workFactor
        self.solutionNonceHex = solutionNonceHex
        self.hashHex = hashHex
    }

    func isValid() -> Bool {
        if let hashHex = hashHex {
            let hashBytes = [UInt8](hex: hashHex)
            let data = Data(hashBytes)
            if let uint64 = data.to(type: UInt64.self) {
                let bigIndian = uint64.bigEndian
                let valid = bigIndian % UInt64(self.workFactor) == 0
                if valid {
                    return true
                }
            }
        }
        return false
    }
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
                                solutionNonceHex: password,
                                hashHex: answer.hexStringValue()
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
