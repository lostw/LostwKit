//
//  CodableExt.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/7/23.
//  Copyright © 2018 kingtang. All rights reserved.
//

import Foundation

public protocol Mapable: Codable {
    static func deserialize(from dict: [String: Any]) -> Self?
    
    func toDict() -> [String: Any]?
    
    static func from(dict: [String: Any]) -> Self?
    static func from(string: String) -> Self?
}

extension Mapable {
    public static func from(dict: [String: Any]) -> Self? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return nil
        }
        
        do {
            let obj = try JSONDecoder().decode(self, from: data)
            return obj
        } catch let err {
            print(err)
            return nil
        }
    }
    
    public static func from(string: String) -> Self? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        do {
            let obj = try JSONDecoder().decode(self, from: data)
            return obj
        } catch let err {
            print(err)
            return nil
        }
    }
    
    @available(*, deprecated, message: "use from(dict:) instead")
    public static func deserialize(from dict: [String: Any]) -> Self? {
        return from(dict: dict)
    }
    
    public func toDict() -> [String: Any]? {
        if let data = try? JSONEncoder().encode(self) {
            return data.toDictionary()
        }
        
        return nil
    }
    
    public func toJsonString() -> String? {
        if let data = try? JSONEncoder().encode(self) {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
}
