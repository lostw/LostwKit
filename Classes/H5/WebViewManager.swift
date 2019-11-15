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
    public static let `default`: WebManager = {
        let manager = WebManager(configuration: WKWebViewConfiguration())
        manager.prepare()
        return manager
    }()

    var reusable: Set<WKWebView> = Set()
    public var configuration: WKWebViewConfiguration
    public var bridageConfig: H5BridgeConfiguration?
    var urlScheme: String?

    public var controllerBuilder: (() -> H5PageController)?
    public var h5Class: AnyClass?

    public var customUserAgent: String?

    public init(configuration: WKWebViewConfiguration) {
        self.configuration = configuration
    }

    @available(iOS 11, *)
    public func enableNativeCache(with handler: WKURLSchemeHandler) {
        let customScheme = "zzscheme"
        self.urlScheme = customScheme
        // 同时处理http跟https的资源
        self.configuration.setURLSchemeHandler(handler, forURLScheme: customScheme)
        self.configuration.setURLSchemeHandler(handler, forURLScheme: customScheme + "s")
    }

    public func getH5Page(link: String, name: String? = nil, params: [String: String]? = nil, h5Controller: H5PageController? = nil) -> H5PageController {
        var h5: H5PageController!

        if let vc = h5Controller {
            h5 = vc
        } else {
            h5 = controllerBuilder?()
        }

        if h5 == nil {
            h5 = H5PageController()
        }

        h5.setLink(link, params: params)
        h5.pageTitle = name
        h5.webView = self.getWebView()

        if let bridageConfig = self.bridageConfig {
            h5.enableCommunication(configuration: bridageConfig)
        }
        if let customScheme = self.urlScheme {
            h5.customScheme = customScheme
        }

        return h5
    }

    public func configH5Page(_ h5: H5PageController) {
        h5.webView = self.getWebView()

    }

    // MAKR: - 预加载webview
    public func prepare() {
        if self.reusable.isEmpty {
            self.reusable.insert(self.buildWebView())
        }
    }

    public func getWebView(configure: ((WKWebView) -> Void)? = nil) -> WKWebView {
        if let item = reusable.popFirst() {

            DispatchQueue.main.async {
                self.prepare()
            }

            return item
        }

        let webview = self.buildWebView()
        configure?(webview)
        self.prepare()
        return webview
    }

    private func buildWebView() -> WKWebView {
        let webview = WKWebView(frame: .zero, configuration: self.configuration)
        webview.customUserAgent = customUserAgent
        return webview
    }
}
