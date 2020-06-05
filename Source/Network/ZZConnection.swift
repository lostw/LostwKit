////
////  ZZConnection.swift
////  Zhangzhilicai
////
////  Created by william on 16/10/2017.
////  Copyright © 2017 william. All rights reserved.
////
//
//import Foundation
//import Alamofire
//
//public protocol ZZNetworkResponseParser {
//    func parse<T>(_ value: T) throws -> [String: Any]
//}
//
//public class ZZNetworkManager {
//    var baseURL: String
//    var session: SessionManager
//    var parser: ZZNetworkResponseParser
//    public init(baseURL: String, parser: ZZNetworkResponseParser) {
//        self.baseURL = baseURL
//        self.session = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
//        self.session.startRequestsImmediately = false
//        self.parser = parser
//    }
//
//    public func getRequest(_ path: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> ZZRequest {
//        let request = session.request(baseURL + path, method: .get, parameters: parameters, encoding: URLEncoding.methodDependent, headers: headers)
//        return ZZRequest(request: request, parser: parser)
//    }
//
//    public func postRequest(_ path: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> ZZRequest {
//        let request = session.request(baseURL + path, method: .post, parameters: parameters, encoding: URLEncoding.methodDependent, headers: headers)
//        return ZZRequest(request: request, parser: parser)
//    }
//}
//
//class ZZConnectionManager {
//    static let shared = ZZConnectionManager()
//
//    var session: SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
//    var queue = [String: ZZRequest]()
//    func enqueue(_ connection: ZZRequest) {
//        self.queue[connection.cacheKey] = connection
//    }
//
//    func dequeue(_ connection: ZZRequest) {
//        self.queue.removeValue(forKey: connection.cacheKey)
//    }
//
//}
//
//public typealias ZZRequestCallback = ([String: Any]?, Error?) -> Void
//public class ZZRequest {
//    enum CacehPolicy {
//        case today, second(TimeInterval), day(TimeInterval)
//        var expiredInterval: TimeInterval {
//            switch self {
//            case .second(let interval): return interval + Date().timeIntervalSince1970
//            case .day(let interval): return interval * 86400 + Date().timeIntervalSince1970
//            case .today: return Date().endOfThisDay().timeIntervalSince1970
//            }
//        }
//    }
//
//    var configuration: URLSessionConfiguration?
//
//    var request: DataRequest
//    var parser: ZZNetworkResponseParser
//
//    var relativePath: String!
//    var parameters: [String: Any]?
//
//    var useCache = false
//    var cachePolicy: CacehPolicy = .second(300)
//    var cacheKey: String
//
//    init(request: DataRequest, parser: ZZNetworkResponseParser) {
//        self.request = request
//        self.parser = parser
//        self.cacheKey = "\(Int(Date().timeIntervalSince1970))\(Int.random(in: 1000..<10000))"
//    }
//
//    public func resume() {
//        self.request.resume()
//    }
//
//    public func suspend() {
//        self.request.suspend()
//    }
//
//    public func cancel() {
//        self.request.cancel()
//    }
//
//    deinit {
//        print("zzconnection deinit")
//    }
//
//    func responseJSON(callback: ZZRequestCallback? = nil) {
//        debugPrint(request)
//        ZZConnectionManager.shared.enqueue(self)
//        self.request.responseJSON {
//            switch $0.result {
//            case .success(let value):
//                guard let dict = value as? [String: Any] else {
//                    callback?(nil, ZZApiError.parseFailure)
//                    return
//                }
//
//                ZLog.info(dict.toJsonString(pretty: true)!)
//                do {
//                    let response = try self.parser.parse(dict)
//                    callback?(response, nil)
//                } catch let err {
//                   callback?(nil, err)
//                }
//            case .failure(let err):
//                if let afError = err as? AFError, afError.isResponseSerializationError {
//                    callback?(nil, ZZError.neFailToParse)
//                } else {
//                    let code = $0.response?.statusCode ?? -1000
//                    callback?(nil, ZZApiError(code: "http\(code)", message: err.localizedDescription))
//                }
//            }
//            ZZConnectionManager.shared.dequeue(self)
//        }
//        self.request.resume()
//    }
//}
