//
//  DefaultRequestBuilder.swift
//  Example
//
//  Created by William on 2020/8/19.
//  Copyright © 2020 Wonders. All rights reserved.
//

import Foundation

public final class DefaultRequestBuilder: RequestBuilder {
    public init() {}
    public func build(baseURL: String, apiName: String, method: ApiRequest.Method, parameters: [String: Any], headers: [String: String]?) -> ApiRequest {
        return ApiRequest(url: "\(baseURL)\(apiName)", method: method, parameters: parameters, headers: headers)
    }
}
