//
//  CommandAppInfo.swift
//  Alamofire
//
//  Created by William on 2020/2/28.
//

import Foundation

public final class CommandAppInfo: H5Command {
    public init() {}
    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        var info = [String: String]()
        info["os"] = "ios"
        info["osVersion"] = UIDevice.current.systemVersion
        info["deviceName"] = deviceIdentifier()
        info["versionName"] = APP_VERSION
        info["versionCode"] = APP_BUILD
        context.triggerCallback(callback, data: info)
    }
}
