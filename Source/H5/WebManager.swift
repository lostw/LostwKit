//
//  WebViewManager.swift
//  HealthTaiZhou
//
//  Created by William on 2019/7/4.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit
import WebKit

public class WebManager {
    public struct Configuration {
        public var viewConfig: WKWebViewConfiguration
        /// 是否激活原生的返回手势（只后退/不前进）
        public var allowBackGesture: Bool = false
        /// jsBridge配置
        public var jsBridgeConfig: H5BridgeConfiguration?
        /// 监测到URL变化后重置页面状态，当前用于SPA
        public var resetPageStateOnURLChange: Bool = true
        /// 自定义User Agent（会抹掉其他信息）, 如果是为了增加标记，使用WKWebViewConfiguration.applicationNameForUserAgent
        public var customUserAgent: String?
        /// 是否重复利用webView
        public var reuseWebView = false

        /// 记录注册的自定义URLScheme
        var resourceScheme: String?
        /// 记录自定义URLScheme时的触发条件;在新打开一个H5PageController时可以校验URL是否符合要求
        var resourceCondition: ((_ url: String) -> Bool)?

        public init(viewConfig: WKWebViewConfiguration, jsBridgeConfig: H5BridgeConfiguration? = nil) {
            self.viewConfig = viewConfig
            self.jsBridgeConfig = jsBridgeConfig
        }

        @available(iOS 12.0, *)
        public mutating func enableResourceHandler(_ handler: WKURLSchemeHandler, in condition: ((String) -> Bool)? = nil) {
            let customScheme = "zzscheme"
            self.resourceScheme = customScheme
            self.resourceCondition = condition
            // 同时处理http跟https的资源
            self.viewConfig.setURLSchemeHandler(handler, forURLScheme: customScheme)
            self.viewConfig.setURLSchemeHandler(handler, forURLScheme: customScheme + "s")
        }
    }
    private var pool: WebViewPool

    /// webView在初始化的时候会copy configuration,
    /// 初始化后不要再修改configuration，保证session的一致性
    let configuration: Configuration
//    public var allowBackGesture = false
//    public var bridgeConfig: H5BridgeConfiguration?
//
//    public var resetOnURLChange = true

    public var pageBuilder: (() -> H5PageController) = {
        return H5PageController()
    }

    public init(configuration: Configuration, isDebug: Bool = false) {
        if isDebug {
            Self.enableDebug(configuration.viewConfig)
        }
        self.configuration = configuration
        self.pool = WebViewPool(configuration: configuration.viewConfig)
    }

    public func getH5Page(link: String, name: String? = nil, params: [String: String]? = nil, h5Controller: H5PageController? = nil) -> H5PageController {
        var h5: H5PageController = h5Controller ?? pageBuilder()
        h5.setupLink(link, params: params)
        h5.pageTitle = name
        h5.session = self
        h5.configuration = configuration.jsBridgeConfig
        h5.resetOnURLChange = configuration.resetPageStateOnURLChange

        if let customScheme = configuration.resourceScheme {
            if let condition = configuration.resourceCondition {
                if condition(link) {
                    h5.customScheme = customScheme
                }
            } else {
                h5.customScheme = customScheme
            }
        }

        return h5
    }

    func getWebView() -> WKWebView {
        let view = self.pool.get()
        view.customUserAgent = configuration.customUserAgent
        return view
    }

    func reuseWebView(_ webView: WKWebView) {
        if configuration.reuseWebView {
            self.pool.put(webView)
        }
    }
}

extension WebManager {
    /// 加载debug.js
    static func enableDebug(_ configuration: WKWebViewConfiguration) {
        let userContentController = configuration.userContentController
        let frameworkBundle = Bundle(for: Theme.self)
        // h5日志
        let filePath = frameworkBundle.path(forResource: "debug", ofType: "js")
        // swiftlint:disable force_try
        let jsContent = try! String(contentsOfFile: filePath!, encoding: .utf8)
        // swiftlint:enable force_try
        let h5Script = WKUserScript(source: jsContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(h5Script)
    }
}

final class WebViewPool {
    private let count = 1
    private var reusable: Set<WKWebView> = Set()
    private let configuration: WKWebViewConfiguration

    init(configuration: WKWebViewConfiguration) {
        self.configuration = configuration
        self.fillPool()
    }

    func get() -> WKWebView {
        defer {
            self.fillPool()
        }
        if let view = reusable.popFirst() {
            return view
        }
        return create()
    }

    func put(_ webView: WKWebView) {
        webView.stopLoading()
        if webView.canGoBack {
            webView.go(to: webView.backForwardList.backList.first!)
        }

        webView.evaluateJavaScript("location.replace('about:blank')")
        reusable.insert(webView)
    }

    func fillPool() {
        DispatchQueue.main.async {
            for _ in self.reusable.count..<self.count {
                let webView = self.create()
                self.reusable.insert(webView)
            }
        }
    }

    func create() -> WKWebView {
        return WKWebView(frame: .zero, configuration: configuration)
    }
}
