//
//  CommandEvent.swift
//  Alamofire
//
//  Created by William on 2020/2/19.
//

import Foundation

public final class CommandBindEvent: H5Command {
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let name = data["name"] as? String,
            let callbackName = data["callbackName"] as? String else {
                return
        }

        let isWholeSession = (data["sessionLifecycle"] as? Bool) ?? false
        context.bindEvent(named: name, callbackName: callbackName, isWholeSession: isWholeSession)
    }
}

public final class CommandTriggerEvent: H5Command {
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let name = data["name"] as? String else {
            return
        }
        let userInfo = data["data"] as? [String: Any]

        context.triggerEvent(named: name, data: userInfo)
    }
}

public final class CommandUnbindEvent: H5Command {
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let name = data["name"] as? String else {
            return
        }

        context.unbindEvent(named: name)
    }
}
