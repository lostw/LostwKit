//
//  H5PageController.swift
//  LostwKit
//
//  Created by William on 2018/11/9.
//  Copyright © 2018 Wonders. All rights reserved.
//

import UIKit
import WebKit

public class H5PageController: UIViewController, UINavigationBack {
    var webView: WKWebView!

    var progressOb: NSKeyValueObservation?
    var pageOb: NSKeyValueObservation?

    var webViewBuilder: WebViewManager!
    var interactiveController: H5BridageController?
    var configuration: H5BridgeConfiguration?

    public var link: String!
    public var pageName: String?
    public var progressEnabled = true
    public var plugin: H5PageControllerPlugin? {
        didSet {
            plugin?.owner = self
        }
    }

    var progressBar: UIProgressView?

    public convenience init(link: String, name: String? = nil, params: [String: String]? = nil, builder: WebViewManager = H5PageManager.defaultWebviewBuilder) {
        self.init()

        var link = link
        link.appendQuery(params)

        self.pageName = name
        self.link = link
        self.webViewBuilder = builder
    }

    deinit {
        self.progressOb = nil
        self.pageOb = nil
    }

    public func shouldGoBack() -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }

        return true
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.pageName ?? "加载中"

        self.commonInitView()
        self.phaseLoadPage()
    }

    func phaseLoadPage() {
        let shouldLoad = self.plugin?.willLoadPage(link: self.link) ?? true
        if shouldLoad {
            loadPage(link: self.link ?? "")
        }
    }

    public func loadPage(link: String) {
        guard let url = URL(string: link) else {
                return
        }
        self.webView.load(URLRequest(url: url))
        self.progressBar?.progress = 0.1
    }

    public func reloadPage() {
        self.webView.reload()
    }

    // MARK: - public methods

    /// 启用交互
    ///
    /// - Parameters:
    ///   - configuration: 配置交互方法、类型名
    public func enableCommunication(configuration: H5BridgeConfiguration) {
        self.configuration = configuration
    }

    // MARK: - private methods
    func commonInitView() {
        self.view.backgroundColor = Theme.shared[.background]

        self.addWebView()
        if let config = self.configuration {
            self.interactiveController = H5BridageController(webview: self.webView, configuration: config, vc: self)
        }

        if self.progressEnabled {
            self.progressBar = UIProgressView()
            self.progressBar!.progressTintColor = UIColor(hex: 0xFDAF3D)
            self.progressBar!.trackTintColor = UIColor.clear
            self.view.addSubview(self.progressBar!)
            self.progressBar!.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(3)
            })

            progressOb = self.webView.observe(\WKWebView.estimatedProgress, options: [.new]) { [unowned self] (_, info) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.progressBar?.progress = Float(info.newValue ?? 0)
                })
            }
        }

        pageOb = self.webView.observe(\.url, options: [.new]) { [unowned self] (_, info) in
            if let url = info.newValue??.absoluteString {
                self.interactiveController?.reload()
                self.resetNavigationBar()

                ZLog.info("[h5]\(url)")
            }
        }
    }

    func resetNavigationBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.title = self.pageName ?? self.webView.title ?? "加载中"
        self.navigationItem.rightBarButtonItem = nil
    }

    func addWebView() {
        self.webView = webViewBuilder.get()
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension H5PageController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var policy = WKNavigationActionPolicy.allow
        let urlStr = navigationAction.request.url?.absoluteString ?? ""

        //处理支付宝支付、微信支付、拨打电话
        if urlStr.starts(with: "alipays://")
            || urlStr.starts(with: "alipay://")
            || urlStr.starts(with: "weixin://")
            || urlStr.starts(with: "tel://") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(navigationAction.request.url!)
            }
            policy = .cancel
        }

        decisionHandler(policy)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.progressBar?.isHidden = false
        self.progressBar?.progress = 0
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.pageName == nil && (self.title == nil || self.title == "加载中") {
            self.title = webView.title
        }

        if self.progressEnabled {
            UIView.animate(withDuration: 0.5, animations: {
                self.progressBar!.progress = 1
            }, completion: { (_) in
                self.progressBar!.isHidden = true
            })
        }
    }

    // js alert 支持
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        self.alert(message: message) { _ in
            completionHandler()
        }
    }

    // 处理window.open(url, _blank)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
            webView.load(navigationAction.request)
        }

        return nil
    }

    @objc func closePage() {
        self.navBack()
    }
}
