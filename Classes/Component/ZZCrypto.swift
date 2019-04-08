//
//  ZZCrypoto.swift
//  Alamofire
//
//  Created by William on 2019/4/1.
//

import Foundation
import CommonCrypto


private let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
public class ZZCrypto {
    public static func md5(_ input: String) -> String {
        let messageData = input.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map {String(format: "%02hhx", $0)}.joined()
    }
    
    public static func sha1(_ str: String) -> String {
        let data = str.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    public static func hmacMD5(_ plainText: String, key: String) -> String {
        let cKey = key.cString(using: .utf8)
        let cData = plainText.cString(using: .utf8)
        
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        
        //    let hmacData = NSData(bytes: result, length: Int(CC_MD5_DIGEST_LENGTH))
        return result.map{String(format: "%02hhx", $0)}.joined()
    }
    
    public static func hmacSHA256(_ plainText: String, key: String) -> String {
        let cKey = key.cString(using: .utf8)
        let cData = plainText.cString(using: .utf8)
        
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        return result.map{String(format: "%02hhx", $0)}.joined()
    }

    public static func generateRandomString(length: Int) -> String {
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            let randomCharactor = characters[index]
            ranStr.append(randomCharactor)
        }
        return ranStr
        
    }
}
