//
//  ApiRequest.swift
//  Example
//
//  Created by William on 2020/8/19.
//  Copyright © 2020 Wonders. All rights reserved.
//

import Foundation
import Alamofire

/// wrap
public class ApiRequest {
    public typealias Callback<Model: Decodable> = (Swift.Result<Model, Error>) -> Void
    public typealias CallbackBool = (Swift.Result<Bool, Error>) -> Void
    public typealias CallbackDict = (Swift.Result<[String: Any], Error>) -> Void
    public enum Method {
        case get, postHttpBody, postJson

        func unwrap() -> (HTTPMethod, ParameterEncoder) {
            switch self {
            case .get:
                return (.get, URLEncodedFormParameterEncoder.default)
            case .postHttpBody:
                return (.post, URLEncodedFormParameterEncoder.default)
            case .postJson:
                return (.post, JSONParameterEncoder.default)
            }
        }

        func oldUnwrap() -> (HTTPMethod, ParameterEncoding) {
            switch self {
            case .get:
                return (.get, URLEncoding.queryString)
            case .postHttpBody:
                return (.post, URLEncoding.httpBody)
            case .postJson:
                return (.post, JSONEncoding.default)
            }
        }
    }

    public let url: String
    public var method: Method = .postJson
    public var parameters: [String: Any] = [:]
    public var headers: [String: String]?

    var request: DataRequest?
    weak var rule: ApiRule?

    public init(url: String, method: Method = .get, parameters: [String: Any] = [:], headers: [String: String]? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
    }

    public func cancel() {
        request?.cancel()
    }

    public func resume() {
        request?.resume()
    }

    public func suspend() {
        request?.suspend()
    }

    func send(_ r: DataRequest, callback: @escaping (Swift.Result<Data, Error>) -> Void) {
        r.validate().cURLDescription {
            ZLog.debug($0)
        }.responseData {
            switch $0.result {
            case .success(let data):
                ZLog.info(String(data: data, encoding: .utf8))
                do {
                    callback(.success(data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    public func responseModel<Model: Decodable>(callback: @escaping Callback<Model>) {
        guard let r = request else { return }
        send(r) { result in
            callback(result.flatMap { data in
                Result<Model, Error>(catching: {
                    try self.rule!.responseHandler.convertToModel(data)
                })
            })
        }
    }

    public func responseBool(callback: @escaping CallbackBool) {
        guard let r = request else { return }
        send(r) { result in
            callback(result.flatMap { data in
                Result<Bool, Error>(catching: {
                    try self.rule!.responseHandler.convertToBool(data)
                })
            })
        }
    }

    public func responseDict(callback: @escaping CallbackDict) {
        guard let r = request else { return }
        send(r) { result in
            callback(result.flatMap { data in
                Result<[String: Any], Error>(catching: {
                    try self.rule!.responseHandler.convertToAnyDict(data)
                })
            })
        }
    }
}
