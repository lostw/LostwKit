//
//  Signature.swift
//  SwiftyRSA
//
//  Created by Loïs Di Qual on 9/19/16.
//  Copyright © 2016 Scoop. All rights reserved.
//

import Foundation
import CommonCrypto

extension RSA {
    public enum DigestType {
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512

        var padding: Padding {
            switch self {
            case .sha1: return .PKCS1SHA1
            case .sha224: return .PKCS1SHA224
            case .sha256: return .PKCS1SHA256
            case .sha384: return .PKCS1SHA384
            case .sha512: return .PKCS1SHA512
            }
        }

        func digest(data: Data) -> Data {
            let length: Int32
            let hash: ((UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?)

            switch self {
            case .sha1:
                length = CC_SHA1_DIGEST_LENGTH
                hash = CC_SHA1
            case .sha224:
                length = CC_SHA224_DIGEST_LENGTH
                hash = CC_SHA224
            case .sha256:
                length = CC_SHA256_DIGEST_LENGTH
                hash = CC_SHA256
            case .sha384:
                length = CC_SHA384_DIGEST_LENGTH
                hash = CC_SHA384
            case .sha512:
                length = CC_SHA512_DIGEST_LENGTH
                hash = CC_SHA512
            }

            var digest = [UInt8](repeating: 0, count: Int(length))
            data.withUnsafeBytes {
                _ = hash($0.baseAddress, CC_LONG(data.count), &digest)
            }

            return Data(bytes: &digest, count: digest.count)
        }
    }
}
