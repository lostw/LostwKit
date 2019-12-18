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
    public var debug = false {
        didSet {
            if debug {
                enableDebugJS()

                if !reusable.isEmpty {
                    reusable.removeAll()
                    prepare()
                }
            }
        }
    }

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
        h5.session = self
        h5.configuration = self.bridageConfig
        
        if let customScheme = self.urlScheme {
            h5.customScheme = customScheme
        }

        return h5
    }

    func enableDebugJS() {
        let userContentController = configuration.userContentController
//        configuration.userContentController = userContentController

        let frameworkBundle = Bundle(for: ZZCrypto.self)
        // h5日志
        let filePath = frameworkBundle.path(forResource: "debug", ofType: "js")
        // swiftlint:disable force_try
        let jsContent = try! String(contentsOfFile: filePath!, encoding: .utf8)
        // swiftlint:enable force_try
        let h5Script = WKUserScript(source: jsContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(h5Script)
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
