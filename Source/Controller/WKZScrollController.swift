//
//  WKZScrollController.swift
//  collection
//
//  Created by william on 09/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public typealias WKZRequestHandler = (@escaping (Bool) -> Void) -> Void
open class WKZScrollController: UIViewController {
    public let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceVertical = true

        return scroll
    }()
    public let contentView = WKZLinearView()
    var requestHandler: WKZRequestHandler?
    var lastFetchDate: Date?
    var requestInterval: TimeInterval = 0
    var willFetchAction: (() -> Void)?

    var bottomInputView: UIView?
    var fixedBottomView: UIView?

    public var isLoadingViewEnabled: Bool = false {
        didSet {
            if isLoadingViewEnabled {
                self.isLoadingViewShown = true
            } else {
                self.isLoadingViewShown = false
            }
        }
    }
    public var isLoadingViewShown: Bool = false {
        didSet {
            self.contentView.isHidden = isLoadingViewShown
            if isLoadingViewShown {
                self.noDataMananger.visible = true
                self.noDataMananger.pageKey = .loading
            } else {
                self.noDataMananger.visible = false
            }
        }
    }
    public let noDataMananger = WKZEmptySetManager()

    fileprivate var keyboardObserved = false
    public var isObserveKeyboard = false {
        didSet {
            if isObserveKeyboard {
                self.addKeyboardObserver()
            } else {
                self.removeKeyboardObserver()
            }
        }
    }
    var tap: UITapGestureRecognizer?
    public var isKeyboardShow = false

    deinit {
        self.scrollView.removePullRefresh()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.commonInitView()
        self.noDataMananger.masterView = self.scrollView
        self.noDataMananger.setErrorRefreshAction { [weak self] in
            self?.noDataMananger.pageKey = .loading
            self?.fetch()
        }
        // Do any additional setup after loading the view.
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isObserveKeyboard {
            self.addKeyboardObserver()
        }

    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isObserveKeyboard {
            self.removeKeyboardObserver()
        }
    }

    open func commonInitView() {
        self.edgesForExtendedLayout = []

        self.view.addSubview(self.scrollView)
        self.scrollView.backgroundColor = Theme.shared[.background]
        self.scrollView.snp.makeConstraints { (make) in
//            if #available(iOS 11.0, *) {
//                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
//            } else {
                make.top.equalToSuperview()
//            }
            make.left.right.bottom.equalToSuperview().offset(0)
        }
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.contentView.ignoreFirstTopMargin = false
        self.contentView.viewHeight = 44
        self.contentView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(self.view.snp.width)
//            make.height.equalTo(self.view.snp.height).priority(.low)
        }
    }
}

// MARK: - handle keyboard event
extension WKZScrollController: UIGestureRecognizerDelegate {
    func addKeyboardObserver() {
        guard !self.keyboardObserved else {
            return
        }

        self.keyboardObserved = true
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardFrameChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        self.tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.tap?.delegate = self
        self.view.addGestureRecognizer(self.tap!)
    }

    func removeKeyboardObserver() {
        guard self.keyboardObserved else {
            return
        }

        self.keyboardObserved = false

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        if let tap = self.tap {
            self.view.removeGestureRecognizer(tap)
        }

    }

    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    @objc func onKeyboardFrameChange(_ notification: Notification) {
        self.isKeyboardShow = true

        let userInfo = notification.userInfo!

        let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect!.height, right: 0)

        if let inputView = self.bottomInputView {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
            let optionCurve = curve<<16
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.init(rawValue: UInt(optionCurve)), animations: {
                inputView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-rect!.height + (isPhoneX() ? 34 : 0))
                }

                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func onKeyboardHide(_ notification: Notification) {
        self.isKeyboardShow = false
        self.scrollView.contentInset = UIEdgeInsets.zero

        if let inputView = self.bottomInputView {
            let userInfo = notification.userInfo!
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
            let optionCurve = curve<<16
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.init(rawValue: UInt(optionCurve)), animations: {
                inputView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(0)
                }

                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer == self.tap else {
            return true
        }

        if self.isKeyboardShow {
            return true
        }

        return false
    }

    public func addFixedBottomView(_ bottomView: UIView, height: CGFloat = 49, isInput: Bool = false, animateIn: Bool = false) {
        self.view.addSubview(bottomView)

        self.fixedBottomView = bottomView
        if isInput {
            self.bottomInputView = bottomView
            self.isObserveKeyboard  = true
        }

        if animateIn {
            bottomView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(isPhoneX() ? (34 + height) : height)
                make.bottom.equalToSuperview().offset(isPhoneX() ? (34 + height) : height)
            }

            self.view.layoutIfNeeded()

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    bottomView.snp.updateConstraints({ (make) in
                        make.bottom.equalToSuperview()
                    })

                    self.scrollView.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().offset(isPhoneX() ? -(34 + height) : -height)
                    }

                    self.view.layoutIfNeeded()
                }, completion: nil)
            }

        } else {
            bottomView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(isPhoneX() ? (34 + height) : height)
            }

            self.scrollView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(isPhoneX() ? -(34 + height) : -height)
            }
        }
    }

    func removeFixedBottomView(animateIn: Bool = false, height: CGFloat = 49) {
        guard let bottomView = self.fixedBottomView else {
            return
        }

        if animateIn {
            UIView.animate(withDuration: 0.3, animations: {
                bottomView.snp.updateConstraints({ (make) in
                    make.bottom.equalToSuperview().offset(isPhoneX() ? (34 + height) : height)
                })

                self.scrollView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(0)
                }

                self.view.layoutIfNeeded()
            }, completion: { _ in
                bottomView.removeFromSuperview()
            })
        } else {
            bottomView.removeFromSuperview()
            self.scrollView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(0)
            }
        }

    }
}

// MARK: - handle request
extension WKZScrollController {
    func fetch(lazyMode: Bool = false) {
        self.willFetchAction?()

        if lazyMode {
            if let date = lastFetchDate, date.timeIntervalSinceNow + requestInterval > 0 {
                return
            }
        }

        if let request = self.requestHandler {
            request { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.lastFetchDate = Date()
                }
                self.scrollView.stopPullRefreshEver()
            }
        }
    }

    func invalidateRequestDate() {
        lastFetchDate = nil
    }

    public func configureRequest(fetchNow: Bool = true, refresh: Bool = true, requestInterval: TimeInterval = 0, handler: WKZRequestHandler? = nil) {
        self.requestHandler = handler
        self.requestInterval = requestInterval
        if handler == nil {
            self.scrollView.removePullRefresh()
        } else {
            if refresh {
                self.scrollView.addPullRefresh { [weak self] in
                    guard let self = self else { return }
                    self.fetch()
                }
            }

            if fetchNow {
                self.fetch()
            }
        }
    }
}
