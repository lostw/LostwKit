//
//  ConsoleDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class ConsoleDestination: BaseDestination {

    /// use NSLog instead of print, default is false
    public var useOSLog = true
    /// uses colors compatible to Terminal instead of Xcode, default is false
    public var useTerminalColors: Bool = false {
        didSet {
            if useTerminalColors {
                // use Terminal colors
                reset = "\u{001b}[0m"
                escape = "\u{001b}[38;5;"
                levelColor.verbose = "251m"     // silver
                levelColor.debug = "35m"        // green
                levelColor.info = "38m"         // blue
                levelColor.warning = "178m"     // yellow
                levelColor.error = "197m"       // red

            } else {
                // use colored Emojis for better visual distinction
                // of log level for Xcode 8
                levelColor.verbose = "💜 "     // silver
                levelColor.debug = "💚 "        // green
                levelColor.info = "💙 "         // blue
                levelColor.warning = "💛 "     // yellow
                levelColor.error = "❤️ "       // red

            }
        }
    }

    override public var defaultHashValue: Int { return 1 }

    public override init() {
        super.init()
        levelColor.verbose = "💜 "     // silver
        levelColor.debug = "💚 "        // green
        levelColor.info = "💙 "         // blue
        levelColor.warning = "💛 "     // yellow
        levelColor.error = "❤️ "       // red
    }

    // print to Xcode Console. uses full base class functionality
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)

        if let str = formattedString {
            if useOSLog {
                os_log("%{public}@", log: OSLog.LostwKit, type: level.osType, str)
            } else {
                print(str)
            }
        }
        return formattedString
    }

}

import os.log
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let LostwKit = OSLog(subsystem: subsystem, category: "LostwKit")
}

extension SwiftyBeaver.Level {
    var osType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .error: return .error
        case .verbose: return .default
        case .warning: return .default
        }
    }
}
