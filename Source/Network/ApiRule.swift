//
//  ApiRule.swift
//  HealthTaiZhou
//
//  Created by William on 2020/5/12.
//  Copyright © 2020 Wonders. All rights reserved.
//

import Foundation
import Alamofire

final public class ApiRule {

    public let baseURL: String
    let session: Session

    public var responseHandler: ResponseHandler
    public var requestBuilder: RequestBuilder

    public init(baseURL: String, requestBuilder: RequestBuilder = DefaultRequestBuilder(), responseHandler: ResponseHandler) {
        self.baseURL = baseURL
        self.responseHandler = responseHandler
        self.requestBuilder = requestBuilder

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        session = Alamofire.Session(configuration: configuration)
    }

    @discardableResult
    public func get(name: String, parameters: [String: Any], headers: [String: String]? = nil) -> ApiRequest {
        return send(name: name, method: .get, parameters: parameters, headers: headers)
    }

    /// post by application/json
    @discardableResult
    public func post(name: String, parameters: [String: Any], headers: [String: String]? = nil) -> ApiRequest {
        return send(name: name, method: .postJson, parameters: parameters, headers: headers)
    }

    /// post by application/x-www-form-urlencoded
    @discardableResult
    public func postForm(name: String, parameters: [String: Any], headers: [String: String]? = nil) -> ApiRequest {
        return send(name: name, method: .postHttpBody, parameters: parameters, headers: headers)
    }

    @discardableResult
    public func send(name: String, method: ApiRequest.Method, parameters: [String: Any], headers: [String: String]? = nil) -> ApiRequest {
        let wrapper = requestBuilder.build(baseURL: baseURL, apiName: name, method: method, parameters: parameters, headers: headers)
        transformToDataRequest(by: wrapper)
//        send(request: dataRequest, callback: callback)

        return wrapper
    }

//    func send<Model>(request: DataRequest, callback: Callback<Model>? = nil) {
//        request.validate().cURLDescription {
//            ZLog.debug($0)
//        }.responseJSON {
//            guard let callback = callback else { return }
//            switch $0.result {
//            case .success(let json):
//                ZLog.info((json as? [String: Any])?.toJsonString() ?? "")
//                do {
//                    let model: Model = try self.responseHandler.convertToModel(json)
//                    callback(.success(model))
//                } catch {
//                    callback(.failure(error))
//                }
//            case .failure(let error):
//                callback(.failure(error))
//            }
//        }
//    }

    private func transformToDataRequest(by zz: ApiRequest) -> DataRequest {
        let request: DataRequest
        if let urlRequest = zz.rawReqeust {
            request = session.request(urlRequest)

        } else {
            var httpHeaders: HTTPHeaders?
            if let headers = zz.headers {
                httpHeaders = HTTPHeaders(headers)
            }

            let (method, encoder) = zz.method.oldUnwrap()

            request = session.request(zz.url, method: method, parameters: zz.parameters, encoding: encoder, headers: httpHeaders)
        }

        zz.request = request
        zz.rule = self
        return request
    }
}
