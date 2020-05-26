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
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileRotateDestination()
        file.fileDestination.minLevel = .debug
        SwiftyBeaver.addDestination(console)
        SwiftyBeaver.addDestination(file)
    }

    public static func error(_ message: Any, function: String = #function, file: String = #file, line: Int = #line) {
        SwiftyBeaver.error(message, file, function, line: line)
    }

    public static func warning(_ message: Any, function: String = #function, file: String = #file, line: Int = #line) {
        SwiftyBeaver.warning(message, file, function, line: line)
    }

    public static func info(_ message: Any, function: String = #function, file: String = #file, line: Int = #line) {
        SwiftyBeaver.info(message, file, function, line: line)
    }

    public static func debug(_ message: Any, function: String = #function, file: String = #file, line: Int = #line) {
        SwiftyBeaver.debug(message, file, function, line: line)
    }

    public static func verbose(_ message: Any, function: String = #function, file: String = #file, line: Int = #line) {
        SwiftyBeaver.verbose(message, file, function, line: line)
    }
}
