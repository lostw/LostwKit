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
    public var session: WebManager?

    var progressOb: NSKeyValueObservation?
    var pageOb: NSKeyValueObservation?
    var titleOb: NSKeyValueObservation?
    var canGobackOb: NSKeyValueObservation?

    /// 封装了javascriptBridage
    public var jsBridge: H5BridgeController?

    /// 配置交互，由在js环境调用postMessage(_ dict: [String: Any])
    public var configuration: H5BridgeConfiguration?

    public var link: String!

    /// 页面标题
    public var pageTitle: String?
    public var progressEnabled = true
    public var plugin: H5PageControllerPlugin? {
        didSet {
            plugin?.page = self
        }
    }

    public var allowBackGesture: Bool = false
    /// 替换http scheme, 用于hook相应的scheme做请求的捕获处理
    public var customScheme: String?
    /// 页面id, 方便查找相应的页面
    public var pageName: String?

    public var shouldProcessURL: ((URL) -> Bool)?

    public var resetOnURLChange: Bool = true

    var startTime: CFAbsoluteTime = 0
    var endTime: CFAbsoluteTime = 0

    var progressBar: UIProgressView?
    public var storageData: [String: Any]?

    public var stateManager: PageStateManager!

    /// 初始化
    /// - Parameters:
    ///   - link: 网页链接
    ///   - pageTitle: 页面标题
    ///   - params: 会转化为get参数拼接在链接上
    public convenience init(link: String, pageTitle: String? = nil, params: [String: String]? = nil) {
        self.init()

        self.pageTitle = pageTitle
        self.link = link.appendingQuries(params)
        self.webView = webView
    }

    deinit {
        self.progressOb = nil
        self.pageOb = nil
        self.titleOb = nil
        self.canGobackOb = nil

        if let webView = self.webView {
            webView.scrollView.removePullRefresh()
            self.session?.reuseWebView(webView)
        }
    }

    public func shouldGoBack() -> Bool {
        // 检查是否设置了返回按钮的事件
        if let callback = self.jsBridge?.currentPage.backAction {
            callback()
            return false
        }

        if webView.canGoBack {
            webView.goBack()
            return false
        }

        return true
    }

    public func setupLink(_ link: String, params: [String: String]? = nil) {
        self.link = link.appendingQuries(params)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.pageTitle ?? "加载中"

        self.commonInitView()

        if allowBackGesture {
            enableBackGesture()
        }
        self.startLoadPage()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 白屏
        if webView.title == nil {
            webView.reload()
        }
    }

    func startLoadPage() {
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
            self.toast.show("URL is not valid")
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

    public func hookBackAction(_ action: @escaping () -> Void) {
        self.jsBridge?.currentPage.backAction = action
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
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        if let config = self.configuration {
            self.jsBridge = H5BridgeController(webview: self.webView, configuration: config, vc: self)
        }

        if self.progressEnabled {
            self.stateManager = PageStateManager(config: .default(PageStateManager.globalConfig))
            self.stateManager.masterView = self.view
//            self.progressBar = UIProgressView()
//            self.progressBar!.progressTintColor = UIColor(hex: 0xFDAF3D)
//            self.progressBar!.trackTintColor = UIColor.clear
//            self.view.addSubview(self.progressBar!)
//            self.progressBar!.snp.makeConstraints({ (make) in
//                make.left.right.top.equalToSuperview()
//                make.height.equalTo(3)
//            })
//
//            progressOb = self.webView.observe(\.estimatedProgress, options: [.new]) { [unowned self] (_, info) in
//                self.stateManager.state = .loading(CGFloat(info.newValue ?? 0))
//            }
        }

        pageOb = self.webView.observe(\.url, options: [.new]) { [unowned self] (_, info) in
            if let url = info.newValue??.absoluteString {
                if self.resetOnURLChange {
                    self.jsBridge?.reload()
                    self.resetNavigationBar()
                }

                ZLog.info("[h5]\(url)")
            }
        }

        if self.pageTitle == nil {
            titleOb = self.webView.observe(\WKWebView.title, options: [.new]) { [unowned self] _, info in
                self.title = info.newValue!
            }
        }
    }

    func enableBackGesture() {
        webView.allowsBackForwardNavigationGestures = true
        canGobackOb = self.webView.observe(\WKWebView.canGoBack, options: [.new], changeHandler: { [unowned self] (_, info) in
            if info.newValue ?? false {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            } else {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }
        })
        DispatchQueue.main.async {
            // 移除侧滑前进手势
            if let gestures = self.webView.gestureRecognizers {
                for g in gestures {
                    if let gesture = g as? UIScreenEdgePanGestureRecognizer,
                       gesture.edges == .right {
                        self.webView.removeGestureRecognizer(gesture)
                    }
                }
            }
        }
    }

    public func resetNavigationBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.title = self.pageTitle ?? self.webView.title ?? "加载中"
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
    }

    func addWebView() {
        // 从session中获取webview 或 自己初始化一个
        self.webView = self.session?.getWebView() ?? WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension H5PageController {
    public func createPageController(link: String, pageTitle: String? = nil, params: [String: String]? = nil) -> H5PageController {
        if let session = session {
            return session.getH5Page(link: link, name: pageTitle, params: params, h5Controller: nil)
        } else {
            return H5PageController(link: link, pageTitle: pageTitle, params: params)
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
        self.jsBridge?.reload()
//        self.progressBar?.isHidden = false
//        self.progressBar?.progress = 0
        self.webView.isHidden = true
        self.stateManager.state = .loading(0)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.progressEnabled {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.progressBar!.progress = 1
//            }, completion: { (_) in
//                self.progressBar!.isHidden = true
//            })
            self.webView.isHidden = false
            self.stateManager.state = .hidden
        }

        self.loadExtraLocalStorage()
        self.plugin?.didLoadPage()
        self.endTime = CFAbsoluteTimeGetCurrent()
        ZLog.debug("load time: \(self.endTime - self.startTime)")
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 请求取消，恢复页面
        if (error as NSError).code == NSURLErrorCancelled {
            self.webView.isHidden = false
            self.stateManager.state = .hidden
            return
        }

        self.stateManager.state = .error(error.localizedDescription)
        ZLog.info(error.localizedDescription)
    }

    // 白屏
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        ZLog.info("[h5]didTerminate")
        webView.reload()
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
