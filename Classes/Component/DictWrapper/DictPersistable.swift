//
//  DictPersistable.swift
//  Alamofire
//
//  Created by William on 2019/11/15.
//

import UIKit

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
