//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import Foundation
import UIKit

public typealias RefreshCompletion = () -> Void

public extension UIScrollView {
    private struct AssociateKeys {
        static var pull        = "com.refresh.pull"
        static var push        = "com.refresh.push"
    }
    var pullManager: PullRefreshManager? {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.pull) as? PullRefreshManager
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.pull, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var pushManager: PushInvisibleManager? {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.push) as? PushInvisibleManager
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.push, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func decorateRefreshViewWithColor(_ color: UIColor) {
//        self.layoutIfNeeded()
        let layer = CAShapeLayer()
        layer.backgroundColor = color.cgColor
        layer.frame = CGRect(x: 0, y: -1000, width: self.frame.size.width, height: 1000+PullToRefreshConst.height)
        self.pullManager?.slaveView.layer.insertSublayer(layer, at: 0)
        self.pullManager?.slaveView.tintColor = UIColor.white
    }

    func addPullRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion: RefreshCompletion?) {
        guard self.pullManager == nil else {
            return
        }

        let refreshViewFrame = CGRect(x: 0, y: -PullToRefreshConst.height, width: self.frame.size.width, height: PullToRefreshConst.height)
        let refreshView = PullRefreshViewSimple(frame: refreshViewFrame, options: options)
        refreshView.tag = PullToRefreshConst.pullTag
        addSubview(refreshView)

        let manager = PullRefreshManager(withIn: self, refreshView: refreshView, refreshCompletion: refreshCompletion!)
        self.pullManager = manager
    }

    func startPullRefresh() {
        self.pullManager?.state = .refreshing
    }

    func stopPullRefreshEver() {
        self.pullManager?.state = .stop
    }

    func removePullRefresh() {
        self.pullManager?.slaveView.removeFromSuperview()
        self.pullManager = nil
    }

    func addPushRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion :(() -> Void)?) {
        guard self.pushManager == nil else {
            return
        }

        let refreshViewFrame = CGRect(x: 0, y: contentSize.height, width: self.frame.size.width, height: PullToRefreshConst.pushHeight)
        let refreshView = PullToLoadMoreView(frame: refreshViewFrame, options: options)
        refreshView.tag = PullToRefreshConst.pullTag
        addSubview(refreshView)

        let manager = PushInvisibleManager(withIn: self, refreshView: refreshView, refreshCompletion: refreshCompletion!)
        self.pushManager = manager
    }

    func startPushRefresh() {
        self.pushManager?.state = .refreshing
    }

    func stopPushRefreshEver(_ ever: Bool = false) {
        if ever {
            self.pushManager?.state = .finish
        } else {
            self.pushManager?.state = .stop
        }
    }

    func removePushRefresh() {
        self.pushManager?.slaveView.removeFromSuperview()
        self.pushManager = nil
    }
}
