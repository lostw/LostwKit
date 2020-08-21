//
//  ZZCrypoto.swift
//  Alamofire
//
//  Created by William on 2019/4/1.
//

import Foundation
import CommonCrypto

public protocol Algorithm {
    func digest(message: String) -> Data
    func doFinal(data: Data) -> Data
}

/// 基本的hash算法
public enum HashAlgorithm: Algorithm {
    case md5
    case sha1
    case sha256

    var length: Int32 {
        switch self {
        case .md5:
            return CC_MD5_DIGEST_LENGTH
        case .sha1:
            return CC_SHA1_DIGEST_LENGTH
        case .sha256:
            return CC_SHA256_DIGEST_LENGTH
        }
    }

    public func digest(message: String) -> Data {
        return self.doFinal(data: message.utf8Data)
    }

    public func doFinal(data: Data) -> Data {
        switch self {
        case .md5:
            let message = [UInt8](data)
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(message, CC_LONG(message.count), &digest)
            return Data(bytes: digest, count: digest.count)
        case .sha1:
            let message = [UInt8](data)
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1(message, CC_LONG(message.count), &digest)
            return Data(bytes: digest, count: digest.count)
        case .sha256:
//            if #available(iOS 13, *) {
//                SHA256.hash(data: data)
//            } else {
                let message = [UInt8](data)
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
                CC_SHA256(message, CC_LONG(message.count), &digest)
                return Data(bytes: digest, count: digest.count)
//            }

        }
    }

    public func callAsFunction(_ message: String) -> String {
        return digest(message: message).toHexString()
    }
}

extension HashAlgorithm {
    var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
        case .md5: return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
        }
    }
}

/// Hmac
public class HmacHash: Algorithm {
    let algorithm: HashAlgorithm
    let key: Data
    public init(algorithm: HashAlgorithm, key: String) {
        self.algorithm = algorithm
        self.key = key.data(using: .utf8)!
    }

    public func digest(message: String) -> Data {
        return self.doFinal(data: message.utf8Data)
    }

    public func doFinal(data: Data) -> Data {
        let keyBytes = [UInt8](key)
        let message = [UInt8](data)

        var digest = [UInt8](repeating: 0, count: Int(algorithm.length))
        CCHmac(algorithm.hmacAlgorithm, keyBytes, keyBytes.count, message, message.count, &digest)
        return Data(bytes: digest, count: digest.count)
    }

    public func callAsFunction(_ message: String) -> String {
        return digest(message: message).toHexString()
    }
}

public class Hash {
    let algorithm: Algorithm
    public init(algorithm: Algorithm) {
        self.algorithm = algorithm
    }

    public func callAsFunction(message: String) -> Data {
        let data = message.data(using: .utf8)!
        return algorithm.doFinal(data: data)
    }
}

public extension Data {
    func toHexString() -> String {
        return self.map {String(format: "%02hhx", $0)}.joined()
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

private let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
extension String {
    public static func random(length: Int) -> String {
        return String((0..<length).map({ _ in characters.randomElement()! }))
    }
}
