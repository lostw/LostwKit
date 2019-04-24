//
//  PullToRefreshFooterView.swift
//  PullDemo
//
//  Created by william on 10/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class PullToRefreshFooterView: UIView {
    enum PullToRefreshState {
        case pulling
        case triggered
        case refreshing
        case stop
        case finish
    }

    var contentOffsetObserver: Any?
    var contentSizeObserver: Any?

    weak var owner: UIScrollView? {
        didSet {
            if let scrollView = self.owner {
                scrollViewInset = scrollView.contentInset
            }
        }
    }

    private var scrollViewInset: UIEdgeInsets!

    fileprivate var options: PullToRefreshOption
    fileprivate var backgroundView: UIView
    fileprivate var contentLabel: UILabel
    //    fileprivate var indicator: UIActivityIndicatorView
    fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
    fileprivate var refreshCompletion: (() -> Void)?
    fileprivate var pull: Bool = false

    fileprivate var positionY: CGFloat = 0 {
        didSet {
            if self.positionY == oldValue {
                return
            }
            var frame = self.frame
            frame.origin.y = positionY
            self.frame = frame
        }
    }

    var state: PullToRefreshState = PullToRefreshState.pulling {
        didSet {
            if self.state == oldValue {
                return
            }
            switch self.state {
            case .stop:
                stopAnimating()
            case .finish:
                //                self.stopAnimating()
                self.showEnd()
            case .refreshing:
                startAnimating()
            case .pulling: //starting point
                //                arrowRotationBack()
                self.contentLabel.text = "加载中..."
            case .triggered:
                //                arrowRotation()
                break
            }
        }
    }

    // MARK: UIView
    public override convenience init(frame: CGRect) {
        self.init(options: PullToRefreshOption(), frame: frame, refreshCompletion: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(options: PullToRefreshOption, frame: CGRect, refreshCompletion :(() -> Void)?, down: Bool=true) {
        self.options = options
        self.refreshCompletion = refreshCompletion

        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.backgroundView.backgroundColor = self.options.backgroundColor
        self.backgroundView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth

        self.contentLabel = UILabel()
        self.contentLabel.font = UIFont.systemFont(ofSize: 10)
        self.contentLabel.textColor = UIColor(hex: 0xaaaaaa)
        self.contentLabel.textAlignment = .center
        self.contentLabel.text = "加载中..."
        self.contentLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        super.init(frame: frame)

        self.addSubview(backgroundView)
        self.addSubview(contentLabel)
        self.autoresizingMask = .flexibleWidth
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

    }

    open override func willMove(toSuperview superView: UIView!) {
        //superview NOT superView, DO NEED to call the following method
        //superview dealloc will call into this when my own dealloc run later!!
        self.removeRegister()
        guard let scrollView = superView as? UIScrollView else {
            return
        }

        contentOffsetObserver = scrollView.observe(\UIScrollView.contentOffset) { [weak self] (scrollView, _) in
            guard let this = self else { return }

            // Pulling State Check
            let offsetY = scrollView.contentOffset.y

            guard scrollView.contentSize.height > scrollView.bounds.size.height else {
                return
            }

            guard this.state != .finish else {
                return
            }

            if this.state != .refreshing {
                let throttle = scrollView.contentSize.height - scrollView.bounds.height - 120
                if offsetY > throttle {
                    this.state = .refreshing
                }
            }
        }

        if !pull {
            contentSizeObserver = scrollView.observe(\UIScrollView.contentSize) { [weak self] (scrollView, _) in
                guard let this = self else { return }
                this.positionY = scrollView.contentSize.height
            }
        }
    }

    fileprivate func removeRegister() {
        contentSizeObserver = nil
        contentOffsetObserver = nil
    }

    deinit {
        self.removeRegister()
    }

    // MARK: private

    fileprivate func startAnimating() {
        //        self.indicator.startAnimating()

        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollViewInsets = scrollView.contentInset

        var insets = scrollView.contentInset
        insets.bottom += self.frame.size.height

        //        scrollView.bounces = false
        UIView.animate(withDuration: PullToRefreshConst.animationDuration,
                       delay: 0,
                       options: [],
                       animations: {
                        scrollView.contentInset = insets
        },
                       completion: { _ in
                        if self.options.autoStopTime != 0 {
                            let time = DispatchTime.now() + Double(Int64(self.options.autoStopTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: time) {
                                self.state = .stop
                            }
                        }
                        self.refreshCompletion?()
        })
    }

    fileprivate func stopAnimating() {
        //        self.indicator.stopAnimating()
        //        self.arrow.isHidden = false
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        //        scrollView.bounces = true
        self.state = .pulling
        let duration = PullToRefreshConst.animationDuration
        UIView.animate(withDuration: duration,
                       animations: {
                        scrollView.contentInset = self.scrollViewInsets
                        //                        self.arrow.transform = CGAffineTransform.identity
        }, completion: { _ in
            //            self.state = .pulling
        })
    }

    func showEnd() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }

        var insets = self.scrollViewInset!
        insets.bottom += self.frame.size.height
        scrollView.contentInset = insets
        self.contentLabel.text = "—— 没有记录了 ——"
    }
}
