//
//  KeychainDictWrapper.swift
//  
//
//  Created by William on 2019/9/17.
//

import UIKit
import KeychainAccess

open class KeychainDictWrapper: DictPersistable {
    public var key: String
    private var keychain: Keychain

    public var dict: [String: Any] = [:]

    public init(key: String) {
        self.key = key
        self.keychain = Keychain()
    }

    public func persist() {
        keychain[key] = ZZJSON.stringify(dict)
    }

    public func recover() {
        if let json = keychain[key], let dict = json.toDict() {
            self.dict = dict
        }
    }
}
