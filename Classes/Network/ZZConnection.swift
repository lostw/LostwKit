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
//class ZZConnectionManager {
//    static let shared = ZZConnectionManager()
//
//    var session: SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
//    var queue = [String: ZZConnection]()
//    func enqueue(_ connection: ZZConnection) {
//        self.queue[connection.cacheKey] = connection
//    }
//
//    func dequeue(_ connection: ZZConnection) {
//        self.queue.removeValue(forKey: connection.cacheKey)
//    }
//
//}
//
//class ZZConnection {
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
//
//    var relativePath: String!
//    var parameters: [String: Any]?
//
//    var useCache = false
//    var cachePolicy: CacehPolicy = .second(300)
//    var cacheKey: String {
//        return ""
////        return AppManager.shared.network.apiDescription(self.relativePath, params: self.parameters)
//    }
//
//    init(name: String, parameters: [String: Any]? = nil, configuration: URLSessionConfiguration? = nil) {
//        self.request = self.buildRequest(name: name, parameters: parameters, configuration: URLSessionConfiguration? = nil)
//    }
//
//    func buildRequest(name: String, parameters: [String: Any]? = nil, configuration: URLSessionConfiguration? = nil) -> DataRequest {
//        var session: SessionManager!
//        if let configuration = configuration {
//            session = SessionManager(configuration: configuration)
//        } else {
//            session = ZZConnectionManager.shared.session
//        }
//
//        return sessionManager.request(tzAppURL + name, method: .post, parameters: postDict, encoding: JSONEncoding.default)
//    }
//
//    deinit {
//        print("zzconnection deinit")
//    }
//
//    func send() {
////        if useCache {
////            if let cache = WKZCache.shared.object(forKey: self.cacheKey) as? [String: Any] {
////                let response = self.convertCacheToResponse(cache)
////                response.isFromCache = true
////                if let callback = self.completion {
////                    callback(response)
////                }
////
////                return
////            }
////        }
//
//        ZZConnectionManager.shared.enqueue(self)
//
//        let request =  self.buildRequest(name: name, parameters: parameters)
//        debugPrint(request)
//        request.responseJSON {
//            switch $0.result {
//            case .success(let value):
//                guard let dict = value as? [String: Any] else {
//                    seal.reject(ZZApiError(message: NetworkErrorDesc.parseFailure))
//                    return
//                }
//
//                ZLog.info(dict.toJsonString(pretty: true)!)
//                do {
//                    let response = try T(dict: dict)
//                    seal.fulfill(response)
//                } catch let err {
//                    seal.reject(err)
//                }
//            case .failure(let err):
//                seal.reject(ZZApiError(code: "http\($0.response!.statusCode)", message: err.localizedDescription))
//            }
//        }
////        AppManager.shared.network.api(self.relativePath, params: self.parameters ?? [String: Any](), method: self.method) { response in
////            if response.isSuccess() {
////                WKZCache.shared.setObject(response.rawDict, forKey: self.cacheKey, expiredAt:  self.cachePolicy.expiredInterval)
////            }
////
////            if let callback = self.completion {
////                callback(response)
////            }
////
////            ZZConnection.dequeue(self)
////        }
//    }
//
//    private func convertCacheToResponse(_ dict: [String: Any]) -> WKZNetworkResponse {
//        return WKZNetworkResponse(dict: dict, data: nil)
//    }
//}
