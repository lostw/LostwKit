//
//  WKZNetwork.swift
//  Zhangzhi
//
//  Created by william on 30/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit
import Alamofire
//import AlamofireImage
import PromiseKit

//@available(*, deprecated, message: "use ZZApiErrorCode")
public struct NetworkErrorDesc {
    public static let unknown = "网络错误"
    public static let messageNotFound = "服务错误，请稍后再试"
    public static let parseFailure = "服务错误(1000)，请稍后再试"
}

public typealias ParameterConfiguration = ([String: Any]?) -> [String: Any]
public typealias ImageDownloadCompletion = (Data?) -> Void

public protocol ZZApiResponse {
    var code: String {get set}
    var message: String {get set}
    var rawDict: [String: Any] {get set}
    var isSuccess: Bool {get}
    init(dict: [String: Any]) throws
}

public enum ZZApiErrorCode: Int {
    case unknown = 900
    case parseFailure = 1000
    case messageNotFound = 1002

    public var description: String {
        switch self {
        case .unknown:
            return "网络错误"
        default:
            return "服务错误(\(self.rawValue))，请稍后再试"
        }
    }
}

public struct ZZApiError: Error, LocalizedError {
    public static let silence = ZZApiError(code: "-", message: "")
    public static let parseFailure = ZZApiError(buildin: .parseFailure)
    public var code: String
    public var message: String

    public init(code: String = "-1", message: String? = nil) {
        self.code = code
        if let message = message {
            self.message = message
        } else {
            self.message = "服务错误(\(code))，请稍后再试"
        }

    }

    public init(buildin errorCode: ZZApiErrorCode) {
        self.code = "x\(errorCode.rawValue)"
        self.message = errorCode.description
    }

    public init(networkError: Error, statusCode: Int?) {
        self.init(code: "http\(statusCode ?? -1)", message: networkError.localizedDescription)
    }

    public var errorDescription: String? {
        return message
    }
}

public protocol ZZJsonApi {
    associatedtype T
    var baseURL: String { get }
    func send(name: String, parameters: [String: Any]) -> Promise<T>
    func buildRequest(name: String, parameters: [String: Any]) -> DataRequest
    func parseResult(_ result: [String: Any]) throws -> T
    func handleUniversalError(_ err: Error)
    func send(request: DataRequest) -> Promise<T>
}

public extension ZZJsonApi {
    @discardableResult
    func send(name: String, parameters: [String: Any]) -> Promise<T> {
        let request = self.buildRequest(name: name, parameters: parameters)
        return send(request: request)
    }

    @discardableResult
    func send(request: DataRequest) -> Promise<T> {
        debugPrint(request)
        return Promise { seal in
            request.responseJSON {
                switch $0.result {
                case .success(let value):
                    guard let dict = value as? [String: Any] else {
                        seal.reject(ZZApiError(buildin: .parseFailure))
                        return
                    }

                    ZLog.info(dict.toJsonString(pretty: true)!)
                    do {
                        let response = try self.parseResult(dict)
                        seal.fulfill(response)
                    } catch let err {
                        self.handleUniversalError(err)
                        seal.reject(err)
                    }
                case .failure(let err):
                    if let afError = err as? AFError, afError.isResponseSerializationError {
                        seal.reject(ZZApiError(buildin: .parseFailure))
                    } else {
                        let code = $0.response?.statusCode ?? -1000
                        seal.reject(ZZApiError(code: "http\(code)", message: err.localizedDescription))
                    }
                }
            }
        }
    }

    func handleUniversalError(_ err: Error) {}
}
