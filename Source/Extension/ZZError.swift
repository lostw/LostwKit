//
//  ZZError.swift
//  Alamofire
//
//  Created by William on 2020/6/1.
//

import Foundation

public typealias ZZApiError = ZZError
public struct ZZError: Error, LocalizedError {
    public static let silence = ZZError(code: "-", message: "")
    public var code: String
    public var message: String

    public init(code: String = "-1", message: String) {
        self.code = code
        self.message = message
    }

    public var errorDescription: String? {
        return message
    }
}

public extension ZZError {
    /// 数据结构不符合预期
    static let neFailToParse = ZZError(apiErrorCode: "1000")
    /// 未找到错误描述
    static let neNoErrorMessage = ZZError(apiErrorCode: "1001")
    /// 列表数据结构不符合预期
    static let neFailToParseList = ZZError(apiErrorCode: "1002")
    /// 转换模型数据失败
    static let neFailToParseModel = ZZError(apiErrorCode: "1003")
    /// 协议方法未实现
    static let protocolMethodNotFound = ZZError(code: "2000", message: "[2000]应用错误")
    /// ApiRule被过早释放
    static let neNoResponseHandler = ZZError(apiErrorCode: "1100")
    /// 不是json数据
    static let neInvalidJson = ZZError(apiErrorCode: "1004")
    /// 不是合法的URL
    static let neInvalidURL = ZZError(apiErrorCode: "1010")

    public init(apiErrorCode: String, message: String? = nil) {
        let networkCode = "NE\(apiErrorCode)"
        let networkMessage = message ?? "[\(networkCode)]服务错误，请稍后再试"
        self.init(code: networkCode, message: networkMessage)
    }

    public init(networkError: Error, statusCode: Int?) {
        let networkCode = "HT\(statusCode ?? -1)"
        let networkMessage = "[\(networkCode)]\(networkError.localizedDescription)"
        self.init(code: networkCode, message: networkMessage)
    }
}

public extension ZZError {
    /// 用户token过期
    static let appTokenExpired = ZZError(code: "4000", message: "[4000]token已失效")
}
