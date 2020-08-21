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
    var responseHandler: ResponseHandler!

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

    public func responseModel<Model: Decodable>(callback: @escaping Callback<Model>) {
        guard let r = request else { return }
        r.validate().cURLDescription {
            ZLog.debug($0)
        }.responseJSON {
            switch $0.result {
            case .success(let json):
                ZLog.info((json as? [String: Any])?.toJsonString() ?? "")
                do {
                    let model: Model = try self.responseHandler.convertToModel(json)
                    callback(.success(model))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    public func responseBool(callback: @escaping CallbackBool) {
        guard let r = request else { return }
        r.validate().cURLDescription {
            ZLog.debug($0)
        }.responseJSON {
            switch $0.result {
            case .success(let json):
                ZLog.info((json as? [String: Any])?.toJsonString() ?? "")
                do {
                    let flag = try self.responseHandler.convertToBool(json)
                    callback(.success(flag))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    public func responseDict(callback: @escaping CallbackDict) {
        guard let r = request else { return }
        r.validate().cURLDescription {
            ZLog.debug($0)
        }.responseJSON {
            switch $0.result {
            case .success(let json):
                ZLog.info((json as? [String: Any])?.toJsonString() ?? "")
                do {
                    let dict = try self.responseHandler.convertToAnyDict(json)
                    callback(.success(dict))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}
