//
//  TimerExt.swift
//  Zhangzhilicai
//
//  Created by william on 17/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

extension Timer {
    public static func scheduledTimer(timeInterval: TimeInterval, repeats: Bool, handler: @escaping () -> Void) -> Timer {
        return self.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(onTimer(_:)), userInfo: handler, repeats: repeats)
    }

    @objc static func onTimer(_ timer: Timer) {
        if let handler = timer.userInfo as? (() -> Void) {
            handler()
        }
    }
}
