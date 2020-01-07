//
//  RSA.swift
//  Alamofire
//
//  Created by William on 2019/12/26.
//
import CommonCrypto

public class RSA {
    public func sign(_ data: Data, with privateKey: String, padding: SecPadding = .PKCS1SHA1) throws -> Data {
        let key = RSAPrivateKey(string: privateKey)
        guard let reference = key.reference else {
            throw SwiftyRSAError.invalidBase64String
        }

        let digest = self.digest(data: data, padding: padding)
        let blockSize = SecKeyGetBlockSize(reference)
        let maxChunkSize = blockSize - 11

        guard digest.count <= maxChunkSize else {
            throw SwiftyRSAError.invalidDigestSize(digestSize: digest.count, maxChunkSize: maxChunkSize)
        }

        var digestBytes = [UInt8](repeating: 0, count: digest.count)
        (digest as NSData).getBytes(&digestBytes, length: digest.count)

        var signatureBytes = [UInt8](repeating: 0, count: blockSize)
        var signatureDataLength = blockSize

        let status = SecKeyRawSign(reference, padding, digestBytes, digestBytes.count, &signatureBytes, &signatureDataLength)

        guard status == noErr else {
            throw SwiftyRSAError.signatureCreateFailed(status: status)
        }

        let signatureData = Data(bytes: UnsafePointer<UInt8>(signatureBytes), count: signatureBytes.count)
        return signatureData
    }

    private func digest(data: Data, padding: SecPadding) -> Data {
        var length: Int32 = 0
        var cipher: ((UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?)! = CC_SHA1


        switch padding {
        case .PKCS1SHA1:
            length = CC_SHA1_DIGEST_LENGTH
            cipher = CC_SHA1
        case .PKCS1SHA224:
            length = CC_SHA224_DIGEST_LENGTH
            cipher = CC_SHA224
        case .PKCS1SHA256:
            length = CC_SHA256_DIGEST_LENGTH
            cipher = CC_SHA256
        default: break
        }

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = cipher($0, CC_LONG(data.count), &digest)
        }
        return Data(bytes: digest, count: Int(length))


    }
}

protocol RSAKey {
    var reference: SecKey? {get set}
    init(string: String)
}

extension RSAKey {
    func retrieveFromKeychain(named name: String) -> SecKey? {
        let queryFilter: [String: Any] = [
            String(kSecClass)             : kSecClassKey,
            String(kSecAttrKeyType)       : kSecAttrKeyTypeRSA,
            String(kSecAttrApplicationTag): name,
            //String(kSecAttrAccessible)    : kSecAttrAccessibleWhenUnlocked,
            String(kSecReturnRef)         : true
        ]

        var keyPtr: AnyObject?
        let result = SecItemCopyMatching(queryFilter as CFDictionary, &keyPtr)
        if result == noErr {
            return keyPtr as! SecKey?
        }

        return nil
    }

    func addKeyToKeychain(data: Data, named name: String, isPrivate: Bool) -> Bool {
        let attrKeyClass = isPrivate ? kSecAttrKeyClassPrivate : kSecAttrKeyClassPublic
        let queryFilter: [String : Any] = [
            (kSecClass as String)              : kSecClassKey,
            (kSecAttrKeyType as String)        : kSecAttrKeyTypeRSA,
            (kSecAttrApplicationTag as String) : name,
            //(kSecAttrAccessible as String)     : kSecAttrAccessibleWhenUnlocked,
            (kSecValueData as String)          : data,
            (kSecAttrKeyClass as String)       : attrKeyClass,
            (kSecReturnPersistentRef as String): true
            ] as [String : Any]
        let result = SecItemAdd(queryFilter as CFDictionary, nil)
        if (result != noErr) && (result != errSecDuplicateItem) {
            NSLog("Cannot add key to keychain, status \(result).")
            return true
        } else {
            return false
        }
    }
}

class RSAPrivateKey: RSAKey {
    var reference: SecKey?

    required init(string: String) {
        let name = "PRIVATE-\(string.hashValue)"
        if let reference = self.retrieveFromKeychain(named: name) {
            self.reference = reference
        } else {
            do {
                let dataDecoded = Data(base64Encoded: string, options: [])!
                self.reference = try self.addRSAPrivateKey(dataDecoded, tagName: name)
            } catch {
                self.reference = nil
            }
        }
    }

    func addRSAPrivateKey(_ privkey: Data, tagName: String) throws -> SecKey? {
        // Delete any old lingering key with the same tag
//        deleteRSAKeyFromKeychain(tagName)

        guard let privkeyData = try stripPrivateKeyHeader(privkey) else {
            return nil
        }

        if addKeyToKeychain(data: privkeyData, named: tagName, isPrivate: true) {
            return retrieveFromKeychain(named: tagName)
        }

        return nil
    }

    private func stripPrivateKeyHeader(_ privkey: Data) throws -> Data? {
        if ( privkey.count == 0 ) {
            return nil
        }

        var keyAsArray = [UInt8](repeating: 0, count: privkey.count / MemoryLayout<UInt8>.size)
        (privkey as NSData).getBytes(&keyAsArray, length: privkey.count)

        //PKCS#8: magic byte at offset 22, check if it's actually ASN.1
        var idx = 22
        if ( keyAsArray[idx] != 0x04 ) {
            return privkey
        }
        idx += 1

        //now we need to find out how long the key is, so we can extract the correct hunk
        //of bytes from the buffer.
        var len = Int(keyAsArray[idx])
        idx += 1
        let det = len & 0x80 //check if the high bit set
        if (det == 0) {
            //no? then the length of the key is a number that fits in one byte, (< 128)
            len = len & 0x7f
        } else {
            //otherwise, the length of the key is a number that doesn't fit in one byte (> 127)
            var byteCount = Int(len & 0x7f)
            if (byteCount + idx > privkey.count) {
                return nil
            }
            //so we need to snip off byteCount bytes from the front, and reverse their order
            var accum: UInt = 0
            var idx2 = idx
            idx += byteCount
            while (byteCount > 0) {
                //after each byte, we shove it over, accumulating the value into accum
                accum = (accum << 8) + UInt(keyAsArray[idx2])
                idx2 += 1
                byteCount -= 1
            }
            // now we have read all the bytes of the key length, and converted them to a number,
            // which is the number of bytes in the actual key.  we use this below to extract the
            // key bytes and operate on them
            len = Int(accum)
        }
        return privkey.subdata(in: idx..<idx+len)
        //return privkey.subdata(in: NSMakeRange(idx, len).toRange()!)
    }
}
