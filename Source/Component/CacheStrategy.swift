//
//  CacheStrategy.swift
//  Alamofire
//
//  Created by William on 2020/8/21.
//

import Foundation

public enum CacheStrategy {
    case today
    case expire(Date)
    case duration(TimeInterval)

    public func isValid(date: Date) -> Bool {
        switch self {
        case .today:
            return date.isToday()
        case .expire(let expireDate):
            return expireDate.timeIntervalSince(date) > 0
        case .duration(let interval):
            return date.timeIntervalSinceNow + interval > 0
        }
    }
}
