//
//  UserDefaultPersistable.swift
//  Alamofire
//
//  Created by William on 2019/4/2.
//

import Foundation

public protocol DictPersistable: AnyObject {
    var key: String {get}
    var dict: [String: Any] {get set}
    func persist()
    func recover()
    func assign(dict: [String: Any])
    func clear()
}

public extension DictPersistable {
    public subscript(key: String) -> Any? {
        get {
            return dict[key]
        }
        set {
            dict[key] = newValue
        }
    }

    func assign(dict: [String: Any]) {
        for (key, value) in dict {
            self.dict[key] = value
        }

        persist()
    }

    public func clear() {
        dict = [:]
        persist()
    }
}

open class UserDefaultsDictWrapper: DictPersistable {
    public var key: String
    public var dict: [String: Any] = [:]

    public init(key: String) {
        self.key = key
    }

    public func persist() {
        UserDefaults.standard.set(dict.toJsonString(), forKey: key)
    }

    public func recover() {
        if let json = UserDefaults.standard.string(forKey: key),
            let dict = json.utf8Data.toDictionary() {
            self.dict = dict
        }
    }
}
