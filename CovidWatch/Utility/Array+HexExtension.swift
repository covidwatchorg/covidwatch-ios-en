//
//  Array+HexExtension.swift
//
//  Created by Madhava Jay on 15/5/20.
//  Copyright © 2020 imkcat. All rights reserved.
//

import Foundation

// code is from CryptoSwift here:
// https://github.com/krzyzanowskim/CryptoSwift/blob/master/Sources/CryptoSwift/Array%2BExtension.swift

extension Array {
  init(reserveCapacity: Int) {
    self = [Element]()
    self.reserveCapacity(reserveCapacity)
  }

  var slice: ArraySlice<Element> {
    self[self.startIndex ..< self.endIndex]
  }
}

// swiftlint:disable identifier_name

extension Array where Element == UInt8 {
  public init(hex: String) {
    self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
    var buffer: UInt8?
    var skip = hex.hasPrefix("0x") ? 2 : 0
    for char in hex.unicodeScalars.lazy {
      guard skip == 0 else {
        skip -= 1
        continue
      }
      guard char.value >= 48 && char.value <= 102 else {
        removeAll()
        return
      }
      let v: UInt8
      let c: UInt8 = UInt8(char.value)
      switch c {
      case let c where c <= 57:
        v = c - 48
      case let c where c >= 65 && c <= 70:
        v = c - 55
      case let c where c >= 97:
        v = c - 87
      default:
        removeAll()
        return
      }
      if let b = buffer {
        append(b << 4 | v)
        buffer = nil
      } else {
        buffer = v
      }
    }
    if let b = buffer {
      append(b)
    }
  }

  public func toHexString() -> String {
    `lazy`.reduce("") {
      var s = String($1, radix: 16)
      if s.count == 1 {
        s = "0" + s
      }
      return $0 + s
    }
  }
}
// swiftlint:enable identifier_name
