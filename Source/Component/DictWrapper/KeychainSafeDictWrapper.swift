//
//  KeychainSafeDictWrapper.swift
//  LostwKit
//
//  Created by William on 2021/5/10.
//

import UIKit
import KeychainAccess

open class KeychainSafeDictWrapper: DictPersistable {
    public var key: String
    private var keychain: Keychain

    public var dict: [String: Any] = [:]

    private var observer: CFRunLoopObserver!
    private var isNeedUpdating = false

    var lock: pthread_mutex_t

    public init(key: String) {
        self.key = key
        self.keychain = Keychain()
        self.lock = pthread_mutex_t()

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
            pthread_mutex_lock(&lock)
            defer {
                pthread_mutex_unlock(&lock)
            }
            return dict[key]

        }
        set {
            pthread_mutex_lock(&lock)
            dict[key] = newValue
            pthread_mutex_unlock(&lock)
            isNeedUpdating = true
        }
    }

    public func recover() {
        if let json = keychain[key], let dict = json.toDict() {
            pthread_mutex_lock(&lock)
            self.dict = dict
            pthread_mutex_unlock(&lock)
        }
    }

    public func assign(dict: [String: Any]) {
        pthread_mutex_lock(&lock)
        for (key, value) in dict {
            self.dict[key] = value
        }
        pthread_mutex_unlock(&lock)
    }

    public func clear() {
        pthread_mutex_lock(&lock)
        dict.removeAll()
        pthread_mutex_unlock(&lock)
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
