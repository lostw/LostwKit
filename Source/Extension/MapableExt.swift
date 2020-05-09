//
//  CodableExt.swift
//  HealthTaiZhou
//
//  Created by william on 2018/7/23.
//  Copyright © 2020 wonders. All rights reserved.
//

import Foundation

public class ModelHelper {
    /// 转换json字符串到模型
    public static func parse<Model: Decodable>(from jsonString: String) -> Model? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        do {
            let obj = try JSONDecoder().decode(Model.self, from: data)
            return obj
        } catch {
            ZLog.error(error.localizedDescription)
            return nil
        }
    }

    // convience method for dict to model
    public static func parse<Model: Decodable>(from value: Any) -> Model? {
        guard let dict = value as? [String: Any] else {
            return nil
        }
        return parse(from: dict)
    }

    /// 转换字典到模型
    /// - Parameter dict: 字典
    /// - Returns: 模型对象
    public static func parse<Model: Decodable>(from dict: [String: Any]) -> Model? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let obj = try JSONDecoder().decode(Model.self, from: data)
            return obj
        } catch {
            ZLog.error(error.localizedDescription)
            return nil
        }
    }

    public static func parse<Model: Decodable>(from list: [Any]) -> [Model] {
        return list.compactMap { ModelHelper.parse(from: $0) }
    }
}

public extension Dictionary {
    func asModel<ModelType: Decodable>() -> ModelType? {
        return ModelHelper.parse(from: self)
    }
}

public extension Array {
    func asModels<ModelType: Decodable>() -> [ModelType] {
        return ModelHelper.parse(from: self)
    }
}

public extension Encodable {
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

// MARK: - Deprecated
@available(*, deprecated, message: "use codable/encodable instead")
public protocol Mapable: Codable {
    func toDict() -> [String: Any]?

    static func from(item: Any) -> Self?
    static func from(dict: [String: Any]) -> Self?
    static func from(string: String) -> Self?

    //    static func from(list: [[String: Any]]) -> [Self]
}

public extension Mapable {
    @available(*, deprecated, message: "use ModelHelper.parse(from:) instead")
    static func from(item: Any) -> Self? {
        guard let dict = item as? [String: Any] else {
            return nil
        }
        return from(dict: dict)
    }

    @available(*, deprecated, message: "use ModelHelper.parse(from:) instead")
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

    @available(*, deprecated, message: "use ModelHelper.parse(from:) instead")
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
}
