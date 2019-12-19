//
//  PushInvisibleManager.swift
//  Alamofire
//
//  Created by William on 2019/12/12.
//

import UIKit

public class PushInvisibleManager {
    unowned var scrollView: UIScrollView

    var contentOffsetObserver: NSKeyValueObservation?
    var contentSizeObserver: NSKeyValueObservation?

    var slaveView: PullRefreshView
    var completion: RefreshCompletion
    var state: PullRefreshState = .pulling(0) {
        didSet {
            switch state {
            case .refreshing:
                self.startAnimating()
            case .stop:
                self.stopAnimating()
            case .finish:
                self.showEnd()
            default: break
            }
            slaveView.state = state
        }
    }
    var scrollInsets: UIEdgeInsets = .zero

    fileprivate var positionY: CGFloat = 0 {
        didSet {
            if self.positionY == oldValue {
                return
            }
            var frame = self.slaveView.frame
            frame.origin.y = positionY
            self.slaveView.frame = frame
        }
    }

    init(withIn scrollView: UIScrollView, refreshView: PullRefreshView, refreshCompletion: @escaping RefreshCompletion) {
        self.scrollView = scrollView
        self.slaveView = refreshView
        self.completion = refreshCompletion
        self.registerObserver()
    }

    deinit {
        removeObserver()
    }

    func registerObserver() {
        contentOffsetObserver = scrollView.observe(\UIScrollView.contentOffset) { [weak self] (scrollView, _) in
            guard let self = self else { return }
            guard scrollView.contentSize.height > scrollView.bounds.height else {
                return
            }

            // Pulling State Check
            let offsetY = scrollView.contentOffset.y
            let throttle = scrollView.contentSize.height - scrollView.bounds.height - 120
            switch self.state {
            case .pulling:
                if offsetY > throttle {
                    self.state = .refreshing
                }
            case .triggered:
                break
            case .refreshing:
                break
            case .stop:
                break
            case .stopped:
                self.state = .pulling(0)
            case .finish:
                break
            }
        }

        contentSizeObserver = scrollView.observe(\UIScrollView.contentSize) { [weak self] (scrollView, _) in
            guard let self = self else { return }
            self.positionY = scrollView.contentSize.height
        }
    }

    func removeObserver() {
        self.contentOffsetObserver = nil
        contentSizeObserver = nil
    }

    func startAnimating() {
        scrollInsets = scrollView.contentInset

        var insets = scrollView.contentInset
        insets.bottom += self.slaveView.bounds.height
        scrollView.bounces = false
        UIView.animate(withDuration: PullToRefreshConst.animationDuration, delay: 0, options: [], animations: {
            self.scrollView.contentInset = insets
        }, completion: { _ in
            self.completion()
        })
    }

    func stopAnimating() {
        scrollView.bounces = true
        let duration = PullToRefreshConst.animationDuration
        UIView.animate(withDuration: duration, animations: {
            self.scrollView.contentInset = self.scrollInsets
        }, completion: { _ in
            self.state = .stopped
        })
    }

    func showEnd() {
        var insets = self.scrollInsets
        insets.bottom += self.slaveView.bounds.height
        scrollView.contentInset = insets
    }
}
