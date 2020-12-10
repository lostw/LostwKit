//
//  Date+String.swift
//  collection
//
//  Created by william on 05/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import SwiftDate

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

    func toFormat(_ format: FormatStyle, locale: LocaleConvertible? = nil) -> String {
        return toFormat(format.rawValue, locale: locale)
    }

    func toString(style: String) -> String {
        let format = DateFormatter()
        format.dateFormat = style
        return format.string(from: self)
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
