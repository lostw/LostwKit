//
//  ZZCrypoto.swift
//  Alamofire
//
//  Created by William on 2019/4/1.
//

import Foundation
import CommonCrypto
import CryptoKit

public protocol Algorithm {
    func digest(message: String) -> Data
    func doFinal(data: Data) -> Data
}

/// 基本的hash算法
public enum HashAlgorithm: Algorithm {
    case md5
    case sha1
    case sha256
    case sha384
    case sha512

    var length: Int32 {
        switch self {
        case .md5:
            return CC_MD5_DIGEST_LENGTH
        case .sha1:
            return CC_SHA1_DIGEST_LENGTH
        case .sha256:
            return CC_SHA256_DIGEST_LENGTH
        case .sha384:
            return CC_SHA384_DIGEST_LENGTH
        case .sha512:
            return CC_SHA512_DIGEST_LENGTH
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
        case .sha384:
            let message = [UInt8](data)
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
            CC_SHA384(message, CC_LONG(message.count), &digest)
            return Data(bytes: digest, count: digest.count)
        case .sha512:
            let message = [UInt8](data)
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
            CC_SHA512(message, CC_LONG(message.count), &digest)
            return Data(bytes: digest, count: digest.count)

        }
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

public extension Hash {
    static func md5(_ message: String) -> String {
        return Hash(algorithm: HashAlgorithm.md5)(message: message).toHexString()
    }

    static func sha256(_ message: String) -> String {
        if #available(iOS 13.0, *) {
            return SHA256.hash(data: message.utf8Data).map {
                String(format: "%02hhx", $0)
            }.joined()
//            return SHA256.hash(data: message.utf8Data).withUnsafeBytes( Data($0))
        } else {
            // Fallback on earlier versions
        }
        return Hash(algorithm: HashAlgorithm.sha256)(message: message).toHexString()
    }

    static func sha364(message: String) -> String {
        return Hash(algorithm: HashAlgorithm.sha384)(message: message).toHexString()
    }

    static func sha512(message: String) -> String {
        return Hash(algorithm: HashAlgorithm.sha512)(message: message).toHexString()
    }
}
