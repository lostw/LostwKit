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

public struct NetworkErrorDesc {
    public static let unknown = "网络错误"
    public static let messageNotFound = "服务字段解析错误"
    public static let parseFailure = "服务解析错误"
}

public typealias ParameterConfiguration = ([String: Any]?) -> [String: Any]
public typealias ImageDownloadCompletion = (Data?) -> Void
//typealias NetworkCompletion = (WKZNetworkResponse) -> Void

public enum WKZRequestMethod: String {
    case get = "GET", post = "POST", delete = "DELETE", put = "PUT", head = "HEAD"
}

public protocol ZZApiResponse {
    var code: String {get set}
    var message: String {get set}
    var rawDict: [String: Any] {get set}
    var isSuccess: Bool {get}
    init(dict: [String: Any]) throws
}



public struct ZZApiError: Error, LocalizedError {
    var code: String
    var message: String
    
    public init(code: String = "-1", message: String = "未知错误") {
        self.code = code
        self.message = message
    }
    
    public init(networkError: Error, statusCode: Int?) {
        self.init(code: "http\(statusCode ?? -1)", message: networkError.localizedDescription)
    }
    
    public var errorDescription: String? {
        return message
    }
}

public protocol ZZJsonApi {
    associatedtype T: ZZApiResponse
    var baseURL: String { get }
    func send(name: String, parameters: [String: Any]) -> Promise<T>
    func buildRequest(name: String, parameters: [String: Any]) -> DataRequest
}

public extension ZZJsonApi {
    func send(name: String, parameters: [String: Any]) -> Promise<T> {
        return Promise { seal in
            let request = self.buildRequest(name: name, parameters: parameters)
            debugPrint(request)
            request.responseJSON {
                switch $0.result {
                case .success(let value):
                    guard let dict = value as? [String: Any] else {
                        seal.reject(ZZApiError(message: NetworkErrorDesc.parseFailure))
                        return
                    }
                    
                    ZLog.info(dict.toJsonString(pretty: true)!)
                    do {
                        let response = try T(dict: dict)
                        seal.fulfill(response)
                    } catch let err {
                        seal.reject(err)
                    }
                case .failure(let err):
                    seal.reject(ZZApiError(code: "http\($0.response!.statusCode)", message: err.localizedDescription))
                }
            }
        }
    }
}

//public class WKZNetworkResponse: NSObject {
//    @objc var code: String
//    @objc var message: String
//    @objc var rawDict: [String: Any]
//    var rawData: Data?
//    var isFromCache = false
//
//
//    init(dict: [String: Any], data: Data?) {
//        if let code = dict["ret_code"] as? String {
//            self.code = code
////            if let resultCode = Int(code) {
////
////            } else {
////                self.code = -1000
////                ZLog.error("错误代码异常code: \(code)")
////            }
//        } else {
//            self.code = "-1000"
//        }
//
//        var message = dict["ret_info"] as? String
//        if message == nil {
//            if self.code == "1004" {
//                message = "操作失败"
//            }
//        }
//
//        self.message = message ?? NetworkErrorDesc.messageNotFound
//        self.rawDict = dict
//        self.rawData = data
//    }
//
//    init(code: String = "-1", message: String = NetworkErrorDesc.unknown, dict: [String: Any] = [:]) {
//        self.code = code
//        self.message = message
//        self.rawDict = dict
//    }
//
//    @objc func isSuccess() -> Bool {
//        return self.code == "0"
//    }
//}

//open class WKZNetwork: NSObject {
//    let baseURLString: String;
//    var parameterConfiguration: ParameterConfiguration?
//
////    lazy var imageDownloader: ImageDownloader  = {
////        return ImageDownloader()
////    }()
//
//
//    static public func network(withBaseURL baseURLString: String, parameterConfiguration: ParameterConfiguration? = nil) -> WKZNetwork {
//        let network = WKZNetwork(baseURLString: baseURLString)
//        network.parameterConfiguration = parameterConfiguration
//        return network
//    }
//
//    init(baseURLString:String) {
//        self.baseURLString = baseURLString
//    }
//
//    @objc func apiDescription(_ relative: String, params: [String: Any]? = [:]) -> String {
//        let parameters = self.parameterConfiguration?(params)
//        var link = self.baseURLString + relative
//
//        link = self.description(withPath: link, params: parameters)
//
//        return link
//    }
//
//    @objc func relativeApi(_ relative: String, params: [String: Any]? = [:], method: String = "get", callback: ((Any?, Error?) -> Void)?) {
//        var parameters: [String: Any]!
//        var link = self.baseURLString + relative
//        var methodType: Alamofire.HTTPMethod = .get
//
//        if method == "get" {
//            methodType = HTTPMethod.get
//            parameters = self.parameterConfiguration?(params)
//        } else {
//            methodType = HTTPMethod.post
//            parameters = params;
//            let tmp = self.parameterConfiguration?(nil)
//            link = self.description(withPath: link, params: tmp)
//        }
//
//
//        ZLog.info("[REQUEST][\(method)]\(self.description(withPath: link, params: parameters))")
//
//
//        Alamofire.request(try! link.asURL(), method: methodType, parameters: parameters).responseJSON { (response) in
//            switch response.result {
//            case .success(let value):
//
//                if let dict = value as? [String: Any] {
//                    ZLog.info("[\(method)]\(self.description(withPath: link, params: parameters)):\n\(dict.toJsonString(pretty: true)!)" )
//                }
//                if let callback = callback {
//                    callback(value, nil)
//                }
//            case .failure(let error):
//                print(error)
//
//                if let errorData = response.data, let errorStr = String(data: errorData, encoding: .utf8) {
//                    ZLog.error("[SERVER]\(self.description(withPath: link, params: parameters)):\n" + errorStr)
//                }
//
//                if let callback = callback, response.response != nil {
//                    callback(nil, NSError(domain: "", code: response.response!.statusCode, userInfo: nil))
//                }
//
//            }
//        }
//    }
//
//    func api(_ relative: String, params: [String: Any] = [:], method: WKZRequestMethod = .get, callback: NetworkCompletion?) {
//        self.request(self.baseURLString + relative, params: params, method: method, callback: callback)
//    }
//
//    func request(_ api: String, params: [String: Any] = [:], method: WKZRequestMethod = .get,  callback: NetworkCompletion?) {
//        var parameters: [String: Any]!
//        var link = api
//        if method == .get {
//            parameters = self.parameterConfiguration?(params)
//        } else {
//            parameters = params;
//            let tmp = self.parameterConfiguration?(nil)
//            link = self.description(withPath: link, params: tmp)
//        }
//
//        ZLog.info("[\(method.rawValue)]\(self.description(withPath: link, params: parameters))")
//
//
//        Alamofire.request(try! link.asURL(), method: HTTPMethod(rawValue: method.rawValue)!, parameters: parameters).responseJSON { (response) in
//            self.handlerResponse(response, for: link, method: method, parameters: parameters, callback: callback)
//        }
//    }
//
//    func upload(_ relative: String, params: [String: Any] = [:], method: WKZRequestMethod = .post, callback: NetworkCompletion?) {
//        var link = self.baseURLString + relative
//        let tmp = self.parameterConfiguration?(nil)
//        link = self.description(withPath: link, params: tmp)
//
//        var parameters = [String: Any]()
//        var images = [String: UIImage]()
//
//        for (key, value) in params {
//            if let image = value as? UIImage {
//                images[key] = image
//            } else {
//                parameters[key] = value
//            }
//        }
//
//        self.upload(link, params: parameters, images: images, callback: callback)
//    }
//
//    func upload(_ api: String, params: [String: Any] = [:], images: [String: UIImage], callback: NetworkCompletion?) {
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            for (key, image) in images {
//                let imgData = image.jpegData(compressionQuality: 0.7)!
//                multipartFormData.append(imgData, withName: key, fileName: key, mimeType: "image/jpeg")
//            }
//
//            for (key, value) in params {
//                let value = String(describing: value)
//                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//            }
//        },
//                         to:api)
//        { (result) in
//            switch result {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    self.handlerResponse(response, for: api, method: .post, parameters: params, callback: callback)
//                }
//
//            case .failure(let encodingError):
//                print(encodingError)
//            }
//        }
//    }
//
//    func handlerResponse(_ response: DataResponse<Any>, for link: String, method: WKZRequestMethod, parameters: [String: Any], callback: NetworkCompletion?) {
//        switch response.result {
//        case .success(let value):
//            if let dict = value as? [String: Any] {
//                ZLog.info("[\(method.rawValue)]\(self.description(withPath: link, params: parameters)):\n\(dict.toJsonString(pretty: true)!)" )
//            }
//
//
//            if let callback = callback {
//                let wrapper = WKZNetworkResponse(dict: value as! [String: Any], data: response.data)
//                callback(wrapper)
//            }
//        case .failure(let error):
//            var errorMsg = "[\(method.rawValue)]\(self.description(withPath: link, params: parameters))"
//            errorMsg += "\n[AF]" + error.localizedDescription
//            if let errorData = response.data, var errorStr = String(data: errorData, encoding: .utf8) {
//                if errorStr.count > 200 {
//                    errorStr = String(errorStr[...errorStr.index(errorStr.startIndex, offsetBy: 200)]) + "..."
//                }
//                errorMsg += "\n[SERVER]" + errorStr
//            }
//            ZLog.error(errorMsg)
//
//            if let callback = callback {
//                var dict = [String: Any]()
//                if let code = response.response?.statusCode {
//                    if code == 502 || code == 503 {
//                        dict["code"] = -2
//                        dict["msg"] = "服务器错误[\(code)]"
//                    }
//                }
//
//                let wrapper = WKZNetworkResponse(dict: [String: Any](), data: response.data)
//                callback(wrapper)
//            }
//
//        }
//    }
//
////    @objc func downloadImageByLink(_ link: String, completion: @escaping ImageDownloadCompletion) {
////        let urlRequest = URLRequest(url: try! link.asURL())
////        self.imageDownloader.download(urlRequest) { response in
////            completion(response.data)
////        }
////    }
//
//    func description(withPath path: String, params: [String: Any]?) -> String {
//        var link = path
//        if let query = params?.toQuery() {
//            if link.range(of: "?") == nil {
//                link = "\(link)?\(query)"
//            } else {
//                link = "\(link)&\(query)"
//            }
//        }
//
//        return link
//    }
//}
