//
//  H5InteractiveTaiZhou.swift
//  HealthTaiZhou
//
//  Created by William on 2019/7/2.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit
import WebViewJavascriptBridge

public typealias H5CmdCallback = WVJBResponseCallback
public protocol H5Command: AnyObject {
    func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridageController)
}

public protocol H5BridgeConfiguration {
    var commandKey: String {get}
    func command(for type: String) -> H5Command?
    func didTriggerCommand(type: String, vc: UIViewController?)
    func didLoadPage(vc: UIViewController?)
}

extension H5BridgeConfiguration {
    public func didTriggerCommand(type: String, vc: UIViewController?) {}
    public func didLoadPage(vc: UIViewController?) {}
}

struct PageInfo {
    subscript(type: String) -> H5Command? {
        return commands[type]
    }
    var commands = [String: H5Command]()
}

public class H5BridageController {
    public var bridge: WebViewJavascriptBridge
    var configuration: H5BridgeConfiguration
    public weak var vc: UIViewController?

    var currentPage: PageInfo!
    var didTriggerAction: ((String) -> Void)?

    public init(webview: WKWebView, configuration: H5BridgeConfiguration, vc: (UIViewController & WKNavigationDelegate)) {
        self.configuration = configuration
        self.vc = vc
        self.bridge = WebViewJavascriptBridge(webview)
        // bridge会变成webview的WKNavigationDelegate, 通过setWebViewDelegate将代理再转出来
        self.bridge.setWebViewDelegate(vc)
        self.bridge.registerHandler("postMessage") { [weak self] (data, callback) in
            guard let self = self else { return }
            if let str = data as? String, let dict = str.toDict() {
                self.dispatch(dict, callback: callback)
            } else if let dict = data as? [String: Any] {
                self.dispatch(dict, callback: callback)
            }
        }
    }

    public func reload() {
        self.currentPage = PageInfo()
        configuration.didLoadPage(vc: self.vc)
    }

    func dispatch(_ data: [String: Any], callback: WVJBResponseCallback?) {
        guard let type = data[configuration.commandKey] as? String else {
            return
        }

        guard self.currentPage != nil else {
            return
        }

        var command = currentPage[type]
        if command == nil {
            command = self.createAction(type: type)
            guard command != nil else {
                ZLog.error("[H5Command]\(type): \(data.toJsonString()!)")
                return
            }

            self.currentPage.commands[type] = command
        }

        if type != "log" {
            ZLog.info("[H5Command]\(type): \(data.toJsonString()!)")
        }

        command!.execute(data, callback: callback, context: self)

        configuration.didTriggerCommand(type: type, vc: self.vc)
    }

//    public func triggerCallback(_ name: String?, data: Any?) {
//        guard let name = name else {
//            return
//        }
//        self.bridge.callHandler(name, data: data)
//    }

    public func triggerCallback(_ callback: WVJBResponseCallback?, data: Any?) {
        guard let callback = callback else {
            return
        }
        let data = data ?? [:]
        callback(ZZJSON.stringify(data))
    }

    func createAction(type: String) -> H5Command? {
        return configuration.command(for: type)
    }
}
