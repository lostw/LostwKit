//
//  ZLog.swift
//  Zhangzhilicai
//
//  Created by william on 19/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public class ZLog {
    public static func enable() {
        let xcodelog = XcodeLogConfiguration(minimumSeverity: .debug)

        var dir = WKZCache.shared.fileCacheURL()
        dir.appendPathComponent("log")
        let filelog = LogFileConfiguration(directoryURL: dir)!
        Log.enable(configuration: [xcodelog, filelog])
    }

    public static func info(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        Log.info?.message(message, function: function, filePath: file, fileLine: line)
    }

    public static func warning(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        Log.warning?.message(message, function: function, filePath: file, fileLine: line)
    }

    public static func error(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        Log.error?.message(message, function: function, filePath: file, fileLine: line)
    }

    public static func debug(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        Log.debug?.message(message, function: function, filePath: file, fileLine: line)
    }
}
