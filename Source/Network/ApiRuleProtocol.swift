//
//  ApiRuleProtocol.swift
//  Example
//
//  Created by William on 2020/8/19.
//  Copyright © 2020 Wonders. All rights reserved.
//

import Foundation

public protocol RequestBuilder {
    func build(baseURL: String, apiName: String, method: ApiRequest.Method, parameters: [String: Any], headers: [String: String]?) -> ApiRequest
}

public protocol ResponseHandler {
    func convertToModel<Model: Decodable>(_ value: Data) throws -> Model
    func convertToBool(_ value: Data) throws -> Bool
    func convertToAnyDict(_ value: Data) throws -> [String: Any]
}

extension ResponseHandler {
    public func convertToBool(_ value: Data) throws -> Bool {
        throw ZZError.protocolMethodNotFound
    }

    public func convertToAnyDict(_ value: Data) throws -> [String: Any] {
        throw ZZError.protocolMethodNotFound
    }
}
