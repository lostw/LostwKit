//
//  H5PageController.swift
//  Zhangzhi
//
//  Created by william on 04/07/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class WebBackView: AlignmentRectView {
    var backButton: UIButton!
    var closeButton: UIButton!
    
    override var insets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInitView() {
        backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "icon_back_white"), for: .normal)
        backButton.frame = CGRect(x: -4, y: (44 - 32) / 2 - 1.5, width: 32, height: 32)
        self.addSubview(backButton)
        
        
        closeButton = UIButton()
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.frame = CGRect(x: 32, y: 4 + 1.5, width: 34, height: 32)
        self.addSubview(closeButton)
    }
}

open class H5PageController: UIViewController {
    public var webView: WKWebView!
    @objc var progressEnabled = true
    fileprivate var progressBar: UIProgressView?
    
    @objc var isFirstPage = false
    public var fixedTitle: String?
    @objc var handlerEnabled = true
    public var URLString: String!
    
    lazy var backView: UIView = {
        let view = WebBackView()
        
        view.backButton.zBind(target: self, action: #selector(historyBack))
        view.closeButton.zBind(target: self, action: #selector(closePage))
        if #available(iOS 11, *) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 80).isActive = true
            view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        } else {
            view.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
        }
        return view;
    }()
    lazy var backItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: self.backView)
    }()
    
    lazy var closeItem: UIBarButtonItem =  {
        return UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closePage))
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.fixedTitle ?? "加载中"
        
        self.commonInitView()
        if self.URLString != nil {
            self.loadURLString()
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        if !self.isFirstPage && self.webView.canGoBack {
        //            self.navigationController?.navigationBar.addSubview(self.backItem)
        //        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        if !self.isFirstPage && self.webView.canGoBack {
        //            self.backItem.removeFromSuperview()
        //        }
    }
    
    open func loadURLString() {
        self.webView.load(URLRequest(url: URL(string: self.URLString!)!))
    }
    
    func process(action: [String: Any]) {
        if let type = action["type"] as? String {
            let selector = NSSelectorFromString("\(type):")
            if self.responds(to: selector) {
                self.perform(selector, with: action)
            }
        }
    }
    
    open func didFinishPage() {
        
    }
    
    open func commonInitView() {
        self.view.backgroundColor = AppTheme.shared[.background]
        
        self.addWebView()
        
        if self.progressEnabled {
            self.progressBar = UIProgressView()
            self.progressBar!.trackTintColor = UIColor.clear
            self.view.addSubview(self.progressBar!)
            self.progressBar!.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(2)
            })
            
            
            self.zObserveKeyPath(self.webView, for: "estimatedProgress", using: { [unowned self] (info, _) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.progressBar?.progress = (info![.newKey] as! NSNumber).floatValue
                })
            })
        }
    }
    
    func addWebView() {
        let configuration = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        
       
        // 与js交互配置代码
//        if self.handlerEnabled {
//            let handler = H5PageWKHandler(owner: self)
//            userContentController.add(handler, name: "appInjection")
//            
//            let filePath = Bundle.main.path(forResource: "injection", ofType: "js")
//            let jsContent = try! String(contentsOfFile: filePath!, encoding: .utf8)
//            let h5Script = WKUserScript(source: jsContent, injectionTime:.atDocumentStart, forMainFrameOnly: true)
//            userContentController.addUserScript(h5Script)
//        }
        
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    public func asyncCallH5Function(name: String, params: String? = nil) {
        DispatchQueue.main.async {
            var js = ""
            if let param = params  {
                js = "\(name)('\(param)')"
            } else {
                js = "\(name)()"
            }
            
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}

extension H5PageController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var policy = WKNavigationActionPolicy.allow
        let urlStr = navigationAction.request.url?.absoluteString ?? ""
        if urlStr.starts(with: "alipays://") || urlStr.starts(with: "alipay://") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(navigationAction.request.url!)
            }
            policy = .cancel
        } else if urlStr.starts(with: "weixin://") {
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
        if self.fixedTitle == nil {
            self.title = webView.title
        }
        
        if self.progressEnabled {
            UIView.animate(withDuration: 0.5, animations: {
                self.progressBar!.progress = 1
            }, completion: { (finished) in
                self.progressBar!.isHidden = true
            })
        }
        
        if self.isFirstPage {
            if webView.canGoBack {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back_white"), style: .plain, target: self, action: #selector(historyBack))
            } else {
                self.navigationItem.leftBarButtonItem = nil
            }
        } else {
            if webView.canGoBack {
                let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                space.width = -8
                self.navigationItem.leftBarButtonItems = [space, self.backItem]
            } else {
                self.navigationItem.leftBarButtonItems = nil
            }
        }
        
        self.didFinishPage()
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
            webView.load(navigationAction.request)
        }
        
        return nil;
    }
    
    
    
    @objc func historyBack() {
        self.webView.goBack()
    }
    
    @objc func closePage() {
        self.navBack()
    }
}

class H5PageWKHandler:NSObject, WKScriptMessageHandler {
    unowned public var owner: H5PageController
    
    init(owner: H5PageController) {
        self.owner = owner
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageBody = message.body
        DispatchQueue.main.async {
            if let content = messageBody as? [String: Any] {
                self.owner.process(action: content)
            } else if let message = messageBody as? String, let dict = message.toDict() {
                self.owner.process(action: dict)
            }
        }
    }
}
