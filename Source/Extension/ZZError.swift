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
    static let neFailToParse = ZZError(apiErrorCode: 1000)
    /// 未找到错误消息描述
    static let neNoErrorMessage = ZZError(apiErrorCode: 1001)

    public init(apiErrorCode: Int, message: String? = nil) {
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
