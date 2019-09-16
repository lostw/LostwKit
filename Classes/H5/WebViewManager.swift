//
//  WebViewManager.swift
//  HealthTaiZhou
//
//  Created by William on 2019/7/4.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit
import WebKit

public class H5PageManager {
    public static let shared = H5PageManager()
    public static let defaultWebviewBuilder = WebViewManager(configuration: WKWebViewConfiguration())
}

public class WebViewManager {
    var reusable: Set<WKWebView> = Set()
    var configuration: WKWebViewConfiguration!

    public init(configuration: WKWebViewConfiguration) {
        self.configuration = configuration
        // 生成一个webview, 加速第一次打开
        self.prepare()
    }

    private func buildWebView() -> WKWebView {
        return WKWebView(frame: .zero, configuration: self.configuration)
    }

    private func prepare() {
        self.reusable.insert(self.buildWebView())
    }

    public func get(configure: ((WKWebView) -> Void)? = nil) -> WKWebView {
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

    func reuse(_ webView: WKWebView) {
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.scrollView.delegate = nil
        webView.stopLoading()
        webView.loadHTMLString("", baseURL: nil)
        self.reusable.insert(webView)
    }
}
