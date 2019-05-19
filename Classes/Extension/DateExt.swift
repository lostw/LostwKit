//
//  Date+String.swift
//  collection
//
//  Created by william on 05/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public enum WKZDateFormatStyle {
    case date, time, datetime, shortDate, sign, shortSign, custom(String)

    var format: String {
        var formatStyle = ""
        switch self {
        case .date: formatStyle = "yyyy-MM-dd"
        case .shortDate: formatStyle = "MM.dd"
        case .time: formatStyle = "HH:mm:ss"
        case .datetime: formatStyle = "yyyy-MM-dd HH:mm:ss"
        case .sign: formatStyle = "yyyyMMddHHmmss"
        case .shortSign: formatStyle = "yyyyMMdd"
        case .custom(let style): formatStyle = style
        }
        return formatStyle
    }

}

public extension Date {
    enum Scale {
        case second, minute, hour, day
    }

    static func fromString(_ str: String, inFormat format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: str)
    }

    static func format(forInterval interval: TimeInterval, style: WKZDateFormatStyle = .date, isMicroSecond: Bool = false) -> String {
        let date = Date(timeIntervalSince1970: (isMicroSecond ? interval / 1000 : interval) )
        return date.format(style)
    }

    static func format(forMicroSecond interval: TimeInterval, style: WKZDateFormatStyle = .date) -> String {
        return self.format(forInterval: interval, style: style, isMicroSecond: true)
    }

    static func yesterday() -> Date {
        return Date().addingTimeInterval(-86400)
    }

    func format(_ style: WKZDateFormatStyle = .date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style.format
        return formatter.string(from: self)
    }

    func isSameDay(forDate date: Date) -> Bool {
//        let calendar = Calendar.current
//        let a = calendar.dateComponents([.era, .year, .month, .day], from: self)
//        let b = calendar.dateComponents([.era, .year, .month, .day], from: date)
//        return a.year! == b.year! && a.month! == b.month! && a.day! == b.day!
        return Calendar.current.isDate(date, inSameDayAs: self)
    }

    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }

    func daysFromToday() -> Int {
        return self.daysFromDate(Date())
    }

    func daysFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let a = calendar.startOfDay(for: self)
        let b = calendar.startOfDay(for: date)

        return Int(a.timeIntervalSince(b)) / 86400
    }

    func endOfThisDay() -> Date {
        let calendar = Calendar.current
        var a = calendar.dateComponents([.era, .year, .month, .day], from: self)
        a.day = a.day! + 1
        return calendar.date(from: a)!
    }

    static func isPast(microSecond: TimeInterval) -> Bool {
        return microSecond / 1000 <= Date().timeIntervalSince1970
    }

    func isPastAfterInterval(_ interval: TimeInterval, scale: Scale = .second) -> Bool {
        switch scale {
        case .second: return timeIntervalSinceNow + interval < 0
        case .minute: return timeIntervalSinceNow + interval * 60 < 0
        case .hour: return timeIntervalSinceNow + interval * 3600 < 0
        case .day: return timeIntervalSinceNow + interval * 86400 < 0
        }
    }

    func addingDays(dDays: Int) -> Date {
        let aTimeInterval = self.timeIntervalSinceReferenceDate + 86400 * Double(dDays)
        let newDate = Date.init(timeIntervalSinceReferenceDate: aTimeInterval)
        return newDate
    }
}

extension TimeInterval {
    func asDate(isMicro: Bool = false) -> Date {
        let date = Date(timeIntervalSince1970: (isMicro ? self / 1000 : self))
        print(date)
        return date
    }
}
