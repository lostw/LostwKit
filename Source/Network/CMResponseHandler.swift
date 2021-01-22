//
//  TZResponseHandler.swift
//  HealthTaiZhou
//
//  Created by William on 2020/5/13.
//  Copyright © 2020 Wonders. All rights reserved.
//

import Foundation

public protocol SuccessValue {}
extension Int: SuccessValue {}
extension String: SuccessValue {}

/// CM is for code and message...
public final class CMResponseHandler: ResponseHandler {
    let codeKey: String
    let successValue: SuccessValue
    let messageKey: String
    let dataKey: String
    let listKeys: [String]
    public init(codeKey: String = "code", successValue: SuccessValue = 0, messageKey: String = "message", dataKey: String = "data", listKeys: [String] = ["list"]) {
        self.codeKey = codeKey
        self.successValue = successValue
        self.messageKey = messageKey
        self.dataKey = dataKey
        self.listKeys = listKeys
    }

    public func convertToBool(_ value: Data) throws -> Bool {
        guard let result = try? JSONSerialization.jsonObject(with: value, options: [.fragmentsAllowed]) as? [String: Any] else {
            throw ZZError.neInvalidJson
        }

        try parseCodeInfo(result)
        return true
    }

    public func convertToAnyDict(_ value: Data) throws -> [String: Any] {
        guard let result = try? JSONSerialization.jsonObject(with: value, options: [.fragmentsAllowed]) as? [String: Any] else {
            throw ZZError.neInvalidJson
        }

        try parseCodeInfo(result)
        if let dict = result[dataKey] as? [String: Any] {
            return dict
        } else {
            throw ZZError.neFailToParseModel
        }
    }

    public func convertToModel<Model: Decodable>(_ value: Data) throws -> Model {
        guard let result = try? JSONSerialization.jsonObject(with: value, options: [.fragmentsAllowed]) as? [String: Any] else {
            throw ZZError.neInvalidJson
        }

        try parseCodeInfo(result)

        if "\(Model.self)".starts(with: "Array<") {
            return try parseAsList(result)
        } else {
            if let dict = result[dataKey] as? [String: Any] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    return try JSONDecoder().decode(Model.self, from: data)
                } catch {
                    throw ZZError.neFailToParseModel
                }
            } else {
                if let model = result[dataKey] as? Model {
                    return model
                } else {
                    throw ZZError.neFailToParseModel
                }
            }
        }
    }

    func parseCodeInfo(_ result: [String: Any]) throws {
        if type(of: successValue) == Int.self {
            guard let code = result[codeKey] as? Int else {
                throw ZZError.neFailToParse
            }

            guard code == (successValue as! Int) else {
                throw ZZError(apiErrorCode: "\(code)", message: result[messageKey] as? String)
            }
        } else {
            guard let code = result[codeKey] as? String else {
                throw ZZError.neFailToParse
            }

            guard code == (successValue as! String) else {
                throw ZZError(apiErrorCode: code, message: result[messageKey] as? String)
            }
        }
    }

    func parseAsList<Model: Decodable>(_ result: [String: Any]) throws -> Model {
        var list: [Any] = []
        if let dataList = result[dataKey] as? [Any] {
            list = dataList
        } else if let dict = result[dataKey] as? [String: Any] {
            if let dataList = self.listData(from: dict) {
                list = dataList
            } else {
                throw ZZError.neFailToParseList
            }
        } else if let dataList = listData(from: result) {
            list = dataList
        } else {
            throw ZZError.neFailToParseList
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: list, options: [])
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            throw ZZError.neFailToParseList
        }
    }

    func listData(from dict: [String: Any]) -> [Any]? {
        let list = self.listKeys
        for key in list {
            if let dataList = dict[key] as? [Any] {
                return dataList
            }
        }

        return nil
    }
}
