//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import Foundation
import UIKit

public extension UIScrollView {
    
    
    var refreshView: PullToRefreshView? {
        return viewWithTag(PullToRefreshConst.pullTag) as? PullToRefreshView
    }
    
    var loadMoreView: PullToRefreshFooterView? {
        return viewWithTag(PullToRefreshConst.pushTag) as? PullToRefreshFooterView
    }
    
    func decorateRefreshViewWithColor(_ color: UIColor) {
//        self.layoutIfNeeded()
        let layer = CAShapeLayer()
        layer.backgroundColor = color.cgColor
        layer.frame = CGRect(x:0, y:-1000, width:self.frame.size.width, height:1000+PullToRefreshConst.height)
        self.refreshView?.layer.insertSublayer(layer, at: 0)
        self.refreshView?.tintColor = UIColor.white
    }
    
    fileprivate func refreshViewWithTag(_ tag:Int) -> PullToRefreshView? {
        let pullToRefreshView = viewWithTag(tag)
        return pullToRefreshView as? PullToRefreshView
    }
    
   
    
    func addPullRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion :(() -> Void)?) {
        guard self.refreshView == nil else {
            return
        }
        let refreshViewFrame = CGRect(x: 0, y: -PullToRefreshConst.height, width: self.frame.size.width, height: PullToRefreshConst.height)
        let refreshView = PullToRefreshView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion)
        refreshView.tag = PullToRefreshConst.pullTag
        addSubview(refreshView)
    }
    
    func addPushRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion :(() -> Void)?) {
        guard self.loadMoreView == nil else {
            return
        }
        
        let refreshViewFrame = CGRect(x: 0, y: contentSize.height, width: self.frame.size.width, height: PullToRefreshConst.pushHeight)
        let refreshView = PullToRefreshFooterView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion)
        refreshView.owner = self
        refreshView.tag = PullToRefreshConst.pushTag
        addSubview(refreshView)
    }
    
    func startPullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.state = .refreshing
    }
    
    func stopPullRefreshEver(_ ever:Bool = false) {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }
    
    func removePullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.removeFromSuperview()
    }
    
    func startPushRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        refreshView?.state = .refreshing
    }
    
    func stopPushRefreshEver(_ ever:Bool = false) {
        let refreshView = self.loadMoreView
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }
    
    func removePushRefresh() {
        self.loadMoreView?.removeFromSuperview()
    }
    
    // If you want to PullToRefreshView fixed top potision, Please call this function in scrollViewDidScroll
    func fixedPullToRefreshViewForDidScroll() {
        let pullToRefreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if !PullToRefreshConst.fixedTop || pullToRefreshView == nil {
            return
        }
        var frame = pullToRefreshView!.frame
        if self.contentOffset.y < -PullToRefreshConst.height {
            frame.origin.y = self.contentOffset.y
            pullToRefreshView!.frame = frame
        }
        else {
            frame.origin.y = -PullToRefreshConst.height
            pullToRefreshView!.frame = frame
        }
    }
}
