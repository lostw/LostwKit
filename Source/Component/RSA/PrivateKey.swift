//
//  PrivateKey.swift
//  SwiftyRSA
//
//  Created by Lois Di Qual on 5/17/17.
//  Copyright © 2017 Scoop. All rights reserved.
//

import Foundation

extension RSA {
    public class PrivateKey: RSAKey {

        /// Reference to the key within the keychain
        public let reference: SecKey

        /// Original data of the private key.
        /// Note that it does not contain PEM headers and holds data as bytes, not as a base 64 string.
        public let originalData: Data?

        let tag: String?

        /// Returns a PEM representation of the private key.
        ///
        /// - Returns: Data of the key, PEM-encoded
        /// - Throws: SwiftyRSAError
        public func pemString() throws -> String {
            let data = try self.data()
            let pem = RSA.format(keyData: data, withPemType: "RSA PRIVATE KEY")
            return pem
        }

        /// Creates a private key with a keychain key reference.
        /// This initializer will throw if the provided key reference is not a private RSA key.
        ///
        /// - Parameter reference: Reference to the key within the keychain.
        /// - Throws: SwiftyRSAError
        public required init(reference: SecKey) throws {

            guard RSA.isValidKeyReference(reference, forClass: kSecAttrKeyClassPrivate) else {
                throw SwiftyRSAError.notAPrivateKey
            }

            self.reference = reference
            self.tag = nil
            self.originalData = nil
        }

        /// Creates a private key with a RSA public key data.
        ///
        /// - Parameter data: Private key data
        /// - Throws: SwiftyRSAError
        required public init(data: Data) throws {
            self.originalData = data
            let tag = UUID().uuidString
            self.tag = tag
            let dataWithoutHeader = try RSA.stripKeyHeader(keyData: data)
//            let finalData = try SwiftyRSA.stripPrivateKeyHeader(dataWithoutHeader)
            reference = try RSA.addKey(dataWithoutHeader, isPublic: false, tag: tag)
        }

        deinit {
            if let tag = tag {
                RSA.removeKey(tag: tag)
            }
        }
    }
}

extension RSA.PrivateKey {
    public func decrypt(base64Encoded: String) throws -> String {
        guard let data = Data(base64Encoded: base64Encoded) else {
            throw SwiftyRSAError.stringToDataConversionFailed
        }

        let decryptedData = try decrypt(data: data)
        guard let str = String(data: decryptedData, encoding: .utf8) else {
            throw SwiftyRSAError.dataToStringConversionFailed
        }

        return str
    }
    /// Decrypts an encrypted message with a private key and returns a clear message.
    ///
    /// - Parameters:
    ///   - key: Private key to decrypt the mssage with
    ///   - padding: Padding to use during the decryption
    /// - Returns: Clear message
    /// - Throws: SwiftyRSAError
    public func decrypt(data: Data, padding: Padding = .PKCS1) throws -> Data {
        let blockSize = SecKeyGetBlockSize(reference)

        let encryptedDataAsArray = [UInt8](data)

        var decryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while idx < encryptedDataAsArray.count {

            let idxEnd = min(idx + blockSize, encryptedDataAsArray.count)
            let chunkData = [UInt8](encryptedDataAsArray[idx..<idxEnd])

            var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var decryptedDataLength = blockSize

            let status = SecKeyDecrypt(reference, padding, chunkData, idxEnd-idx, &decryptedDataBuffer, &decryptedDataLength)
            guard status == noErr else {
                throw SwiftyRSAError.chunkDecryptFailed(index: idx)
            }

            decryptedDataBytes += [UInt8](decryptedDataBuffer[0..<decryptedDataLength])

            idx += blockSize
        }

        let decryptedData = Data(bytes: UnsafePointer<UInt8>(decryptedDataBytes), count: decryptedDataBytes.count)
        return decryptedData
    }

    public func sign(message: String) throws -> String {
        let signedData = try sign(data: message.data(using: .utf8)!)
        return signedData.base64EncodedString()
    }

    /// Signs a clear message using a private key.
    /// The clear message will first be hashed using the specified digest type, then signed
    /// using the provided private key.
    ///
    /// - Parameters:
    ///   - key: Private key to sign the clear message with
    ///   - digestType: Digest
    /// - Returns: Signature of the clear message after signing it with the specified digest type.
    /// - Throws: SwiftyRSAError
    public func sign(data: Data, digestType: RSA.DigestType = .sha1) throws -> Data {
        let digest = digestType.digest(data: data)
        let blockSize = SecKeyGetBlockSize(reference)
        let maxChunkSize = blockSize - 11

        guard digest.count <= maxChunkSize else {
            throw SwiftyRSAError.invalidDigestSize(digestSize: digest.count, maxChunkSize: maxChunkSize)
        }

        let digestBytes = [UInt8](digest)

        var signatureBytes = [UInt8](repeating: 0, count: blockSize)
        var signatureDataLength = blockSize

        let status = SecKeyRawSign(reference, digestType.padding, digestBytes, digestBytes.count, &signatureBytes, &signatureDataLength)

        guard status == noErr else {
            throw SwiftyRSAError.signatureCreateFailed(status: status)
        }

        let signatureData = Data(bytes: UnsafePointer<UInt8>(signatureBytes), count: signatureBytes.count)
        return signatureData
    }
}
