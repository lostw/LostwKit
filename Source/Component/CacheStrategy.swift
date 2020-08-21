//
//  CacheStrategy.swift
//  Alamofire
//
//  Created by William on 2020/8/21.
//

import Foundation
import SwiftDate

public enum CacheStrategy {
    case today
    case expire(Date)
    case duration(TimeInterval)

    public func isValid(date: Date) -> Bool {
        switch self {
        case .today:
            return date.compare(.isToday)
        case .expire(let expireDate):
            return date.isBeforeDate(expireDate, granularity: .second)
        case .duration(let interval):
            return date.timeIntervalSinceNow + interval > 0
        }
    }
}
