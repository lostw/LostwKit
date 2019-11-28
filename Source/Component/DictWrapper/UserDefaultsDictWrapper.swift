//
//  UserDefaultPersistable.swift
//  Alamofire
//
//  Created by William on 2019/4/2.
//

import Foundation

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
