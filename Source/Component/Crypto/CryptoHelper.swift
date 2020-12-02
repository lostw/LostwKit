//
//  CryptoHelper.swift
//  LostwKit
//
//  Created by William on 2020/12/2.
//

import Foundation

public extension Data {
    func toHexString() -> String {
        return self.map {String(format: "%02hhx", $0)}.joined()
    }

    func toUtf8String() -> String? {
        return String(data: self, encoding: .utf8)
    }

    func toBase64() -> String {
        self.base64EncodedString()
    }

    func toBase64Url() -> String {
        var base = self.base64EncodedString()
        base.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base
    }
}

public extension String {
    /// 二进制字符串转Data
    func hexToData() -> Data {
        let list = Array(self)
        var result: Data = Data()
        for i in stride(from: 0, to: list.count, by: 2) {
            let byte = UInt8("\(list[i])\(list[i+1])", radix: 16)!
            result.append(byte)
        }
        return result
    }
}

private let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
extension String {
    public static func random(length: Int) -> String {
        return String((0..<length).map({ _ in characters.randomElement()! }))
    }
}
