//
//  H5InteractiveTaiZhou.swift
//  HealthTaiZhou
//
//  Created by William on 2019/7/2.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit
import WebKit

public typealias H5CmdCallback = WKWebViewJavascriptBridgeBase.Callback
public protocol H5Command: AnyObject {
    init()
    func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController)
}

public enum H5BridgeEntryType {
    case single(_ entryName: String, _ commandName: String)
    case independent(_ allCommandNames: [String])
}

public protocol H5BridgeConfiguration {
    var entryType: H5BridgeEntryType { get }
    func command(for type: String) -> H5Command?
    func didTriggerCommand(type: String, vc: UIViewController?)
    func didLoadPage(vc: UIViewController?)
}

extension H5BridgeConfiguration {
    public func didTriggerCommand(type: String, vc: UIViewController?) {}
    public func didLoadPage(vc: UIViewController?) {}
}

public struct PageInfo {
    public struct OberverInfo {
        var name: String
        var observer: NSObjectProtocol
        var callbackName: String
        var isWholeSession: Bool
    }

    public var pageName: String?
    public var backAction: (() -> Void)?
    public var observerInfo: [String: OberverInfo] = [:]

    public init() {}

    public func clearObserver() {
        self.observerInfo.values.forEach {
            NotificationCenter.default.removeObserver($0.observer)
        }
    }

    /// 删除当前页的信息，只保留整个webview生命周期的监听事件
    mutating func clear() {
        self.pageName = nil
        self.backAction = nil
        self.observerInfo = self.observerInfo.filter {
            if !$0.value.isWholeSession {
                NotificationCenter.default.removeObserver($0.value.observer)
                return false
            }
            return true
        }
    }
}

public extension Notification.Name {
    static let LogRequest = Notification.Name("LogRequest")
    static let LogResponse = Notification.Name("LogResponse")
}

public class H5BridgeController {
    var bridge: WebViewJSBridge
    var configuration: H5BridgeConfiguration
    public weak var vc: H5PageController?

    var currentPage = PageInfo()
    var didTriggerAction: ((String) -> Void)?

    public init(webview: WKWebView, configuration: H5BridgeConfiguration, vc: (H5PageController & WKNavigationDelegate)) {
        self.configuration = configuration
        self.vc = vc
        self.bridge = WebViewJSBridge(webView: webview)
        // bridge会变成webview的WKNavigationDelegate, 通过setWebViewDelegate将代理再转出来
        webview.navigationDelegate = vc
//        self.bridge.setWebViewDelegate(vc)
        self.bridge.registerHandler("logMessage") { data, _ in
            if let data = data {
                ZLog.info("[H5log]\(data)")
            } else {
                ZLog.info("[H5log]Empty")
            }

        }
        self.bridge.registerHandler("logResponse") { data, _ in
            NotificationCenter.default.post(name: .LogResponse, object: nil, userInfo: data as? [String: Any])
            if let data = data {
                ZLog.info("[H5Request]\(data)")
            }
        }
        // callback是一次性的，使用过后js环境会丢弃掉
        switch configuration.entryType {
        case let .single(entryName, commandKey):
            self.bridge.registerHandler(entryName) { [weak self] (data, callback) in
                guard let self = self else { return }
                let dict = self.parseRawData(data)
                guard let type = dict[commandKey] as? String else {
                    return
                }
                self.executeCommand(named: type, with: dict, callback: callback)
            }
        case .independent(let names):
            for name in names {
                self.bridge.registerHandler(name) { [weak self] (data, callback) in
                    guard let self = self else { return }
                    let dict = self.parseRawData(data)
                    self.executeCommand(named: name, with: dict, callback: callback)
                }
            }
        }
    }

    deinit {
        self.currentPage.clearObserver()
    }

    public func reload() {
        self.currentPage.clear()
        configuration.didLoadPage(vc: self.vc)
    }

    func parseRawData(_ data: Any?) -> [String: Any] {
        if let str = data as? String, let dict = str.toDict() {
            return dict
        } else if let dict = data as? [String: Any] {
            return dict
        } else {
            return [:]
        }
    }

    func executeCommand(named type: String, with data: [String: Any], callback: H5CmdCallback?) {
        ZLog.info("[H5Command]\(type): \(data.toJsonString()!)")
        guard let command = configuration.command(for: type) else {
            return
        }
        command.execute(data, callback: callback, context: self)
        configuration.didTriggerCommand(type: type, vc: self.vc)
    }

    public func callH5Func(named name: String?, data: Any?) {
        guard let name = name else {
            return
        }
        self.bridge.callHandler(name, data: data)
    }

    public func triggerCallback(_ callback: H5CmdCallback?, data: Any?) {
        guard let callback = callback else {
            return
        }
        callback(data)
    }

    func createAction(type: String) -> H5Command? {
        return configuration.command(for: type)
    }
}

extension H5BridgeController {
    public func bindEvent(named name: String, callbackName: String, isWholeSession: Bool = false) {
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: nil) { [weak self] n in
            guard let self = self else { return }
            self.callH5Func(named: callbackName, data: n.userInfo)
        }

        // 防止重复绑定
        if let exist = self.currentPage.observerInfo[name] {
            self.unbindEvent(named: name)
        }

        let info = PageInfo.OberverInfo(name: name, observer: observer, callbackName: callbackName, isWholeSession: isWholeSession)
        self.currentPage.observerInfo[name] = info
    }

    public func triggerEvent(named name: String, data: [String: Any]?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil, userInfo: data)
    }

    public func unbindEvent(named name: String) {
        guard let info = self.currentPage.observerInfo[name] else { return }
        NotificationCenter.default.removeObserver(info.observer)
        self.currentPage.observerInfo[name] = nil
    }
}
