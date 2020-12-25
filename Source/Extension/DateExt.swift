//
//  Date+String.swift
//  collection
//
//  Created by william on 05/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public extension DateFormatter {
    static let `default`: DateFormatter = {
        let format = DateFormatter()
        format.locale = .autoupdatingCurrent
        return format
    }()
}

public extension Date {
    public enum FormatStyle: String {
        case date = "yyyy-MM-dd"
        case time = "HH:mm:ss"
        case datetime = "yyyy-MM-dd HH:mm:ss"
        case datetimeShort = "yyyyMMddHHmmss"
    }

    var interval: TimeInterval {
        return timeIntervalSince1970
    }

    /// 毫秒级timeInterval
    var mInterval: TimeInterval {
        return timeIntervalSince1970 * 1000
    }

    func toFormat(_ format: FormatStyle) -> String {
        return toString(style: format.rawValue)
    }

    func toString(style: String) -> String {
        let format = DateFormatter.default
        format.dateFormat = style
        return format.string(from: self)
    }

    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
}

public extension TimeInterval {
    func degrade() -> TimeInterval {
        return self / 1000
    }

    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}
