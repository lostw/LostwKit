//
//  WKZNetwork.swift
//  Zhangzhi
//
//  Created by william on 30/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit
import Alamofire

//@available(*, deprecated, message: "use ZZApiErrorCode")
public struct NetworkErrorDesc {
    public static let unknown = "网络错误"
    public static let messageNotFound = "服务错误，请稍后再试"
    public static let parseFailure = "服务错误(1000)，请稍后再试"
}

public typealias ParameterConfiguration = ([String: Any]?) -> [String: Any]
public typealias ImageDownloadCompletion = (Data?) -> Void
