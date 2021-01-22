//
//  AES.swift
//  LostwKit
//
//  Created by William on 2020/12/2.
//

import Foundation
import CommonCrypto

public class AES {
    public class CBC {
        var key: Data
        var iv: Data

        public init(key: Data, iv: Data) throws {
            guard key.count == kCCKeySizeAES128 ||
                    key.count == kCCKeySizeAES192 ||
                    key.count == kCCKeySizeAES256 else {
                throw ZZError(code: "-1", message: "unsupport key size")
            }

            self.key = key
            self.iv = iv
        }

        public func encrypt(_ plain: Data) throws -> Data {
            let keyBytes = [UInt8](self.key)
            let ivBytes = [UInt8](self.iv)
            let plainBytes = [UInt8](plain)
            var result = [UInt8](repeating: 0, count: plainBytes.count + kCCBlockSizeAES128)
            var length = 0

            let status = CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes, self.key.count, ivBytes, plainBytes, plainBytes.count, &result, plainBytes.count + kCCBlockSizeAES128, &length)
            if status == 0 {
                return Data(Array(result[0..<length]))
            } else {
                throw ZZError(code: "\(status)", message: "Encrypt Failed")
            }
        }

        public func decrypt(_ cipher: Data) throws -> Data {
            let keyBytes = [UInt8](self.key)
            let ivBytes = [UInt8](self.iv)
            let cipherBytes = [UInt8](cipher)
            var result = [UInt8](repeating: 0, count: cipherBytes.count + kCCBlockSizeAES128)
            var length = 0

            let status = CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes, self.key.count, ivBytes, cipherBytes, cipherBytes.count, &result, cipherBytes.count + kCCBlockSizeAES128, &length)
            if status == 0 {
                return Data(Array(result[0..<length]))
            } else {
                throw ZZError(code: "\(status)", message: "Decrypt Failed")
            }
        }
    }
}

public extension AES.CBC {
    convenience init(key: String, iv: String) throws {
        try self.init(key: key.utf8Data, iv: iv.utf8Data)
    }

    func encrypt(_ plain: String) throws -> String {
        return try encrypt(plain.utf8Data).toHexString()
    }

    func decrypt(_ cipher: String) throws -> String {
        if let result = try decrypt(cipher.hexToData()).toUtf8String() {
            return result
        } else {
            throw ZZError(code: "-1", message: "Invalid Utf8 String")
        }
    }
}
