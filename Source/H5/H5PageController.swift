//
//  H5PageController.swift
//  LostwKit
//
//  Created by William on 2018/11/9.
//  Copyright © 2018 Wonders. All rights reserved.
//

import UIKit
import WebKit

open class H5PageController: UIViewController, UINavigationBack {
    public var webView: WKWebView!

    // 初始化当前页面的manager, 可以传递相同的配置
    unowned public var session: WebManager = WebManager.default

    var progressOb: NSKeyValueObservation?
    var pageOb: NSKeyValueObservation?

    /// 封装了javascriptBridage
    public var bridgeController: H5BridgeController?

    /// 配置交互，由在js环境调用postMessage(_ dict: [String: Any])
    public var configuration: H5BridgeConfiguration?

    public var link: String!

    /// 页面标题
    public var pageTitle: String?
    public var progressEnabled = true
    public var plugin: H5PageControllerPlugin? {
        didSet {
            plugin?.owner = self
        }
    }

    /// 替换http scheme, 用于hook相应的scheme做请求的捕获处理
    public var customScheme: String?
    /// 页面id, 方便查找相应的页面
    public var pageName: String?

    public var shouldProcessURL: ((URL) -> Bool)?

    var startTime: CFAbsoluteTime = 0
    var endTime: CFAbsoluteTime = 0

    var progressBar: UIProgressView?
    public var storageData: [String: Any]?

    /// 初始化
    /// - Parameters:
    ///   - link: 网页链接
    ///   - pageTitle: 页面标题
    ///   - params: 会转化为get参数拼接在链接上
    public convenience init(link: String, pageTitle: String? = nil, params: [String: String]? = nil) {
        self.init()

        var link = link
        link.appendQuery(params)

        self.pageTitle = pageTitle
        self.link = link
        self.webView = webView
    }

    deinit {
        self.progressOb = nil
        self.pageOb = nil

        self.webView.scrollView.removePullRefresh()
    }

    public func shouldGoBack() -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }

        return true
    }

    public func setLink(_ link: String, params: [String: String]? = nil) {
        var link = link
        link.appendQuery(params)
        self.link = link
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.pageTitle ?? "加载中"

        self.commonInitView()
        self.phaseLoadPage()
    }

    /// 插件机制
    func phaseLoadPage() {
        let shouldLoad = self.plugin?.willLoadPage(link: self.link) ?? true
        if shouldLoad {
            loadPage(link: self.link ?? "")
        }
    }

    public func loadPage(link: String) {
        var parsed = link
        if let customScheme = self.customScheme {
            parsed.replaceFirst(matching: "http", with: customScheme)
        }

        guard let url = URL(string: parsed) else {
            return
        }

        let request = self.buildRequest(url)
        self.webView.load(request)
        self.progressBar?.progress = 0.1
    }

    /// 生成URLRequest，继承可以增加自定义的配置
    open func buildRequest(_ url: URL) -> URLRequest {
        return URLRequest(url: url)
    }

    public func reloadPage() {
        self.webView.reload()
    }

    /// 页面结束加载时可以设置额外的localStorage
    func loadExtraLocalStorage() {
        // 用于恢复上个页面的localstorage
        if let dict = self.storageData {
            let js = """
            var obj = \(dict.toJsonString()!)
            for (var item in obj) {
                localStorage.setItem(item, obj[item])
            }
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    /// 获取页面的localStorage
    public func asyncGetLocalStorage(_ callback: @escaping ([String: Any]?) -> Void) {
        let js = """
            var dict = {}
            for ( var i = 0, len = localStorage.length; i < len; ++i ) {
            var key = localStorage.key( i )
            dict[key] = localStorage.getItem(key)
                    }
            dict
            """

        self.webView.evaluateJavaScript(js) { info, _ in
            callback(info as? [String: Any])
        }
    }

    /// 增加刷新
    public func toggleRefresh(_ flag: Bool) {
        if flag {
            self.webView.scrollView.addPullRefresh { [weak self] in
                guard let self = self else { return }

                self.webView.reload()
                self.webView.scrollView.stopPullRefreshEver()
            }
        } else {
            self.webView.scrollView.removePullRefresh()
        }
    }

    // MARK: - private methods
    func commonInitView() {
        self.view.backgroundColor = Theme.shared.background

        self.addWebView()
        if let config = self.configuration {
            self.bridgeController = H5BridgeController(webview: self.webView, configuration: config, vc: self)
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
                self.bridgeController?.reload()
                self.resetNavigationBar()

                ZLog.info("[h5]\(url)")
            }
        }
    }

    func resetNavigationBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.title = self.pageTitle ?? self.webView.title ?? "加载中"
        self.navigationItem.rightBarButtonItem = nil
    }

    func addWebView() {
        // 从session中获取webview
        self.webView = self.session.getWebView()
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension H5PageController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        var policy = WKNavigationActionPolicy.allow

        let urlStr = url.absoluteString

        //处理支付宝支付、微信支付、拨打电话
        if urlStr.starts(with: "alipays://")
            || urlStr.starts(with: "alipay://")
            || urlStr.starts(with: "weixin://")
            || urlStr.starts(with: "tel://") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            policy = .cancel
        } else if let plugin = self.plugin {
            policy = plugin.shouldProcessRequest(navigationAction.request) ? .allow : .cancel
        }

        decisionHandler(policy)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.startTime = CFAbsoluteTimeGetCurrent()
        self.progressBar?.isHidden = false
        self.progressBar?.progress = 0
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.pageTitle == nil && (self.title == nil || self.title == "加载中") {
            self.title = webView.title
        }

        if self.progressEnabled {
            UIView.animate(withDuration: 0.5, animations: {
                self.progressBar!.progress = 1
            }, completion: { (_) in
                self.progressBar!.isHidden = true
            })
        }

        self.loadExtraLocalStorage()

        self.endTime = CFAbsoluteTimeGetCurrent()
        ZLog.debug("load time: \(self.endTime - self.startTime)")
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ZLog.info(error.localizedDescription)
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
}
