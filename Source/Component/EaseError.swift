//
//  ZZError.swift
//  Alamofire
//
//  Created by William on 2019/12/3.
//

import UIKit

public struct EaseError: Error, LocalizedError {
    public enum Domain {
        case unknown, network, custom(String)

        public var description: String {
            switch self {
            case .network: return "network"
            case .custom(let value): return value
            default: return "unknown"
            }
        }
    }
    public var code: Int
    public var message: String = ""
    public var domain: Domain = .unknown

    public init(code: Int = -1, message: String, domain: Domain = .unknown) {
        self.code = code
        self.message = message
        self.domain = domain
    }

    public var errorDescription: String? {
        return message
    }
}
