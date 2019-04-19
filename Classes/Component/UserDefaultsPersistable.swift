//
//  UserDefaultPersistable.swift
//  Alamofire
//
//  Created by William on 2019/4/2.
//

import Foundation

public protocol UserDefaultsPersistable: AnyObject {
    var key: String {get}
    var info: [String: Any] {get set}
    func persist()
    func recover()
    func assign(dict: [String: Any])
    func clear()
}

public extension UserDefaultsPersistable {
    subscript(key: String) -> String? {
        return info[key] as? String
    }
    
    func persist() {
        UserDefaults.standard.set(info.toJsonString(), forKey: key)
    }
    
    func recover() {
        if let json = UserDefaults.standard.string(forKey: key),
            let dict = json.utf8Data.toDictionary() {
            info = dict
        }
    }
    
    func assign(dict: [String: Any]) {
        for (key, value) in dict {
            info[key] = value
        }
        
        persist()
    }
    
    func clear() {
        info = [:]
        persist()
    }
}
