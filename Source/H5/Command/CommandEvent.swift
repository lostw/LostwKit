//
//  CommandEvent.swift
//  Alamofire
//
//  Created by William on 2020/2/19.
//

import Foundation

public class CommandBindEvent: H5Command {
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let name = data["name"] as? String,
            let callbackName = data["callbackName"] as? String else {
                return
        }

        context.bindEvent(named: name, callbackName: callbackName)
    }
}

public class CommandTriggerEvent: H5Command {
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let name = data["name"] as? String else {
            return
        }
        let userInfo = data["data"] as? [String: Any]

        context.triggerEvent(named: name, data: userInfo)
    }
}

public class CommandUnbindEvent: H5Command {
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let name = data["name"] as? String else {
            return
        }

        context.unbindEvent(named: name)
    }
}
