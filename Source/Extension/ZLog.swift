//
//  ZLog.swift
//  Zhangzhilicai
//
//  Created by william on 19/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public typealias ZLog = SwiftyBeaver

public extension ZLog {
    static func enable() {
        let console = ConsoleDestination()  // log to Xcode Console
        console.format = "$DHH:mm:ss.SSS$d $C$N:$l - $M"
        let file = FileRotateDestination()
        file.fileDestination.minLevel = .debug

        console.minLevel = .verbose
        SwiftyBeaver.addDestination(console)
        SwiftyBeaver.addDestination(file)
    }
}
