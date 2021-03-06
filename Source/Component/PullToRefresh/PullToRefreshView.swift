//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//  Qiulang rewrites it to support pull down & push up
//
import UIKit

open class PullToRefreshView: UIView {
    var contentOffsetObserver: NSKeyValueObservation?

    fileprivate var options: PullToRefreshOption
    fileprivate var backgroundView: UIView
    fileprivate var arrow: PullToRefreshArrow
    fileprivate var indicator: UIActivityIndicatorView
    fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
    fileprivate var refreshCompletion: (() -> Void)?

    open override var tintColor: UIColor! {
        didSet {
            self.arrow.color = tintColor
            self.indicator.color = tintColor
            self.arrow.setNeedsDisplay()
        }
    }

    public var state: PullToRefreshState = PullToRefreshState.pulling {
        didSet {
            if self.state == oldValue {
                return
            }
            switch self.state {
            case .stop:
                stopAnimating()
            case .finish:
                var duration = PullToRefreshConst.animationDuration
                var time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.stopAnimating()
                }
                duration *= duration
                time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.removeFromSuperview()
                }
            case .refreshing:
                startAnimating()
            case .pulling: //starting point
                arrowRotationBack()
            case .triggered:
                arrowRotation()
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

        self.arrow = PullToRefreshArrow(frame: CGRect(x: 0, y: 0, width: 20, height: 22))
        self.arrow.backgroundColor = UIColor.clear
        self.arrow.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]

        self.indicator = UIActivityIndicatorView(style: .gray)
        self.indicator.bounds = self.arrow.bounds
        self.indicator.autoresizingMask = self.arrow.autoresizingMask
        self.indicator.hidesWhenStopped = true
        self.indicator.color = options.indicatorColor

        super.init(frame: frame)
        self.addSubview(indicator)
        self.addSubview(backgroundView)
        self.addSubview(arrow)
        self.autoresizingMask = .flexibleWidth
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.arrow.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
//        self.arrow.frame = arrow.frame.offsetBy(dx: 0, dy: 0)
        self.indicator.center = self.arrow.center
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
            this.scrollViewDidScroll(scrollView)
        }
    }

    func removeRegister() {
        contentOffsetObserver = nil
    }

    deinit {
        self.removeRegister()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Pulling State Check
        let offsetY = scrollView.contentOffset.y

        // Alpha set
        if PullToRefreshConst.alpha {
            var alpha = abs(offsetY) / (self.frame.size.height + 40)
            if alpha > 0.8 {
                alpha = 0.8
            }
            self.arrow.alpha = alpha
        }

        let throttle = -self.bounds.height - scrollView.contentInset.top

        if offsetY < throttle {
            if scrollView.isDragging && self.state == .pulling {
                self.state = .triggered
            } else if !scrollView.isDragging && self.state == .triggered {
                self.state = .refreshing
            }
        } else {
            if self.state == .triggered {
                self.state = .pulling
            }
        }
    }

    // MARK: private

    fileprivate func startAnimating() {
        self.indicator.startAnimating()
        self.arrow.isHidden = true
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollViewInsets = scrollView.contentInset

        var insets = scrollView.contentInset
        insets.top += self.frame.size.height
        scrollView.bounces = false
        UIView.animate(withDuration: PullToRefreshConst.animationDuration,
                                   delay: 0,
                                   options: [],
                                   animations: {
            scrollView.contentInset = insets
        }, completion: { _ in
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
        self.indicator.stopAnimating()
        self.arrow.isHidden = false
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollView.bounces = true
        let duration = PullToRefreshConst.animationDuration
        UIView.animate(withDuration: duration,
                                   animations: {
                                    scrollView.contentInset = self.scrollViewInsets
                                    self.arrow.transform = CGAffineTransform.identity
                                    }, completion: { _ in
            self.state = .pulling
        }
        )
    }

    fileprivate func arrowRotation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            // -0.0000001 for the rotation direction control
            self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 0.0000001)
        }, completion: nil)
    }

    fileprivate func arrowRotationBack() {
        UIView.animate(withDuration: 0.2, animations: {
            self.arrow.transform = CGAffineTransform.identity
        })
    }
}

class PullToRefreshArrow: UIView {
    var color = UIColor(hex: 0x555555)
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            self.color.setStroke()
            ctx.setLineWidth(1)

            ctx.move(to: CGPoint(x: rect.width / 2, y: 20))
            ctx.addLine(to: CGPoint(x: rect.width / 2, y: 0))
            ctx.closePath()

            ctx.move(to: CGPoint(x: 6, y: 14))
            ctx.addLine(to: CGPoint(x: rect.width / 2, y: 20))
            ctx.closePath()

            ctx.move(to: CGPoint(x: rect.width - 6, y: 14))
            ctx.addLine(to: CGPoint(x: rect.width / 2, y: 20))
            ctx.closePath()

            ctx.strokePath()
        }
    }
}
