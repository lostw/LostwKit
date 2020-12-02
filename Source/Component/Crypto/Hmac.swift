//
//  Hmac.swift
//  LostwKit
//
//  Created by William on 2020/12/2.
//

import Foundation
import CommonCrypto

extension HashAlgorithm {
    var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
        case .md5: return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384: return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
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

    public func callAsFunction(message: String) -> Data {
        return digest(message: message)
    }
}

public extension HmacHash {
    static func md5(_ message: String, key: String) -> String {
        return HmacHash(algorithm: HashAlgorithm.md5, key: key)(message: message).toHexString()
    }

    static func sha1(_ message: String, key: String) -> String {
        return HmacHash(algorithm: HashAlgorithm.sha1, key: key)(message: message).toHexString()
    }

    static func sha256(_ message: String, key: String) -> String {
        return HmacHash(algorithm: HashAlgorithm.sha256, key: key)(message: message).toHexString()
    }

    static func sha384(_ message: String, key: String) -> String {
        return HmacHash(algorithm: HashAlgorithm.sha384, key: key)(message: message).toHexString()
    }

    static func sha512(_ message: String, key: String) -> String {
        return HmacHash(algorithm: HashAlgorithm.sha512, key: key)(message: message).toHexString()
    }
}
