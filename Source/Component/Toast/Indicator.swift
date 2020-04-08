//
//  Indicator.swift
//  Alamofire
//
//  Created by William on 2019/12/9.
//

import UIKit

public protocol IndicatorView: UIView {
    var text: String? { get set }
    func startAnimating()
    func stopAnimating()
}

public class Indicator: NSObject {
    var count: Int = 0
    unowned var masterView: UIView
    lazy var slaveView: IndicatorView = {
        if let view = customView {
            return view
        }

        if let view = ToastManager.shared.loadingViewBuilder?() {
            return view
        }

        let style = ToastManager.shared.style
        let activityView = DefaultIndicatorView()
        activityView.frame =
        CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height)
        activityView.layer.cornerRadius = style.cornerRadius
        activityView.backgroundColor = style.activityBackgroundColor
        activityView.tintColor = style.activityIndicatorColor

        return activityView
    }()
    public var customView: IndicatorView?

    lazy var fadeInAnimation: Animator = Animator(type: .fadeIn) { _ in
        self.isFadeIn = false
    }

    lazy var fadeOutAnimation = Animator(type: .fadeOut) { finished in
        self.isFadeOut = false
        if finished {
            self.slaveView.removeFromSuperview()
        }
    }

    var isFadeIn = false
    var isFadeOut = false

    public init(withIn view: UIView) {
        self.masterView = view
    }

    /// show indictorView by increasing count
    /// - Parameter text: text to be shown
    public func show(_ text: String? = nil) {
        count += 1
        if count > 0 {
            masterView.isUserInteractionEnabled = false
            slaveView.text = text
        }

        guard slaveView.superview == nil else {
            if isFadeOut {
                cancelFadeOut()
            }
            return
        }

        slaveView.center = CGPoint(x: masterView.bounds.width / 2, y: masterView.bounds.height / 2)
        masterView.addSubview(slaveView)
        slaveView.startAnimating()
        fadeIn()
    }

    /// update text while not changing count
    /// - Parameter text: text to be shown
    public func update(_ text: String?) {
        slaveView.text = text
    }

    /// hide indciatorView by decreasing count
    public func hide() {
        count -= 1
        if count <= 0 {
            masterView.isUserInteractionEnabled = true
            if isFadeIn {
                cancelFadeIn()
            }

            fadeOut()
        }
    }

    ///  reset count, hide indicatorView
    public func reset() {
        count = 0
        slaveView.layer.removeAllAnimations()
        slaveView.removeFromSuperview()
    }

    private func fadeIn() {
        isFadeIn = true
        slaveView.layer.add(fadeInAnimation.animation, forKey: "fadeIn")
    }

    private func fadeOut() {
        isFadeOut = true
        slaveView.layer.add(fadeOutAnimation.animation, forKey: "fadeOut")
    }

    private func cancelFadeIn() {
        slaveView.layer.removeAnimation(forKey: "fadeIn")
        slaveView.removeFromSuperview()
    }

    private func cancelFadeOut() {
        slaveView.layer.removeAnimation(forKey: "fadeOut")
    }
}

enum AnimationType {
    case fadeIn, fadeOut

    var animation: CABasicAnimation {
        switch self {
        case .fadeIn:
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.3
            animation.fromValue = 0
            animation.toValue = 1
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            return animation
        case .fadeOut:
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.3
            animation.fromValue = 1
            animation.toValue = 0
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            return animation
        }
    }
}

final class Animator: NSObject, CAAnimationDelegate {
    let animation: CABasicAnimation
    var onCompletion: ((Bool) -> Void)?

    init(type: AnimationType, completion: ((Bool) -> Void)? = nil) {
        self.animation = type.animation
        self.onCompletion = completion
        super.init()
        self.animation.delegate = self
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.onCompletion?(flag)
    }
}
