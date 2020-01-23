//
//  CodableExt.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/7/23.
//  Copyright © 2018 kingtang. All rights reserved.
//

import Foundation

public protocol Mapable: Codable {
    func toDict() -> [String: Any]?

    static func from(dict: [String: Any]) -> Self?
    static func from(string: String) -> Self?

    static func form(list: [[String: Any]]) -> [Self]
}

public extension Mapable {
     static func from(dict: [String: Any]) -> Self? {
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

    static func from(string: String) -> Self? {
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

    static func from(list: [[String: Any]]) -> [Self] {
        return list.compactMap { self.from(dict: $0) }
    }

    func toDict() -> [String: Any]? {
        if let data = try? JSONEncoder().encode(self) {
            return data.toDictionary()
        }

        return nil
    }

    func toJsonString() -> String? {
        if let data = try? JSONEncoder().encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

}
