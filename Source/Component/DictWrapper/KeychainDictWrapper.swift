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

    private var observer: CFRunLoopObserver!
    private var isNeedUpdating = false

    public init(key: String) {
        self.key = key
        self.keychain = Keychain()

        self.observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { [unowned self] (_, _) in
            self.persist()
        })
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), self.observer, CFRunLoopMode.commonModes)
    }

    deinit {
        CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observer, CFRunLoopMode.commonModes)
    }

    public subscript(key: String) -> Any? {
        get {
            dict[key]
        }
        set {
            dict[key] = newValue
            isNeedUpdating = true
        }
    }

    public func recover() {
        if let json = keychain[key], let dict = json.toDict() {
            self.dict = dict
        }
    }

    public func assign(dict: [String: Any]) {
        for (key, value) in dict {
            self.dict[key] = value
        }
    }

    public func clear() {
        dict.removeAll()
        isNeedUpdating = true
    }

    public func persist() {
        guard isNeedUpdating else {
            return
        }
        if dict.isEmpty {
            keychain[key] = nil
        } else {
            keychain[key] = ZZJson.stringify(dict)
        }

        isNeedUpdating = false
    }
}
