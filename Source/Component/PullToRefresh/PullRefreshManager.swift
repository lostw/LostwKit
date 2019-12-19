//
//  PullRefreshManager.swift
//  Alamofire
//
//  Created by William on 2019/12/11.
//

import UIKit

public class PullRefreshManager {
    unowned var scrollView: UIScrollView

    var contentOffsetObserver: NSKeyValueObservation?

    var slaveView: PullRefreshView
    var completion: RefreshCompletion
    var state: PullRefreshState = .pulling(0) {
        didSet {
            switch state {
            case .refreshing:
                self.startAnimating()
            case .stop:
                self.stopAnimating()
            default: break
            }
            slaveView.state = state
        }
    }
    var scrollInsets: UIEdgeInsets = .zero

    public init(withIn scrollView: UIScrollView, refreshView: PullRefreshView, refreshCompletion: @escaping RefreshCompletion) {
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
            guard let self = self, self.slaveView.superview != nil else { return }

            // Pulling State Check
            let offsetY = self.scrollView.contentOffset.y + self.scrollView.contentInset.top
            let throttle = -self.slaveView.bounds.height

            switch self.state {
            case .pulling:
                if offsetY < throttle && self.scrollView.isDragging {
                    self.state = .triggered
                } else {
                    self.state = .pulling(offsetY / throttle)
                }
            case .triggered:
                if offsetY < throttle {
                    if !self.scrollView.isDragging {
                        self.state = .refreshing

                    }
                } else {
                    self.state = .pulling(offsetY / throttle)
                }
            case .refreshing:
                break
            case .stop:
                break
            case .stopped:
                self.state = .pulling(offsetY / throttle)
            case .finish:
                break
            }
        }
    }

    func removeObserver() {
        self.contentOffsetObserver = nil
    }

    func startAnimating() {
        scrollInsets = scrollView.contentInset

        var insets = scrollView.contentInset
        insets.top += slaveView.bounds.height
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
}
