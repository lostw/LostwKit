//
//  ZZConnection.swift
//  Zhangzhilicai
//
//  Created by william on 16/10/2017.
//  Copyright © 2017 william. All rights reserved.
//

//import Foundation
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
//    static var queue = [String: ZZConnection]()
//    static func enqueue(_ connection: ZZConnection) {
//        self.queue[connection.cacheKey] = connection
//    }
//    
//    static func dequeue(_ connection: ZZConnection) {
//        self.queue.removeValue(forKey: connection.cacheKey)
//    }
//    
//    var relativePath: String!
//    var parameters: [String: Any]?
//    var method = WKZRequestMethod.get
//    var completion: NetworkCompletion?
//    
//    var useCache = false
//    var cachePolicy: CacehPolicy = .second(300)
//    var cacheKey: String {
//        return ""
////        return AppManager.shared.network.apiDescription(self.relativePath, params: self.parameters)
//    }
//    
//    init(path: String, method: WKZRequestMethod = .get, parameters:  [String: Any]? = nil, completion: NetworkCompletion?) {
//        self.relativePath = path
//        self.method = method
//        self.parameters = parameters
//        self.completion = completion
//    }
//    
//    deinit {
//        print("zzconnection deinit")
//    }
//    
//    func send() {
//        if useCache {
//            if let cache = WKZCache.shared.object(forKey: self.cacheKey) as? [String: Any] {
//                let response = self.convertCacheToResponse(cache)
//                response.isFromCache = true
//                if let callback = self.completion {
//                    callback(response)
//                }
//                
//                return
//            }
//        }
//       
//        ZZConnection.enqueue(self)
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
