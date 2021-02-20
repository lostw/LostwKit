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

class IndicatorManager {
    static let shared = IndicatorManager()

    var viewsToChange: [Indicator] = []

    var observer: CFRunLoopObserver!
    init() {
        self.observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, { [weak self] (_, _) in
            for item in self!.viewsToChange {
                item.makeChange()
            }
            self!.viewsToChange.removeAll()
        })
        CFRunLoopAddObserver(CFRunLoopGetMain(), self.observer, CFRunLoopMode.commonModes)
    }

    deinit {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer, CFRunLoopMode.commonModes)
    }

    func add(_ item: Indicator) {
        if let _ = viewsToChange.firstIndex { $0 === item } {
            return
        }
        viewsToChange.append(item)
    }

    func remove(_ item: Indicator) {
        if let index = viewsToChange.firstIndex { $0 === item } {
            viewsToChange.remove(at: index)
        }
    }
}

public class Indicator {
    enum State {
        case hidden, fadeIn, showing, fadeOut
    }

    var prevCount: Int = 0
    var count: Int = 0 {
        didSet {
            if isNeedChange {
                IndicatorManager.shared.add(self)
            } else {
                IndicatorManager.shared.remove(self)
            }
        }
    }

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

    lazy var fadeInAnimation: Animator = Animator(type: .fadeIn) { [weak self] _ in
        guard let self = self else { return }
        if self.state == .fadeIn {
            self.state = .showing
        }
    }

    lazy var fadeOutAnimation = Animator(type: .fadeOut) { [weak self] _ in
        guard let self = self else { return }
        if self.state == .fadeOut {
            self.state = .hidden
        }
    }

    var state: State = .hidden {
        didSet {
            switch state {
            case .hidden:
                self.slaveView.removeFromSuperview()
                self.masterView.isUserInteractionEnabled = true
            case .fadeIn:
                masterView.isUserInteractionEnabled = false
                slaveView.center = CGPoint(x: masterView.bounds.width / 2, y: masterView.bounds.height / 2)
                masterView.addSubview(slaveView)
                slaveView.startAnimating()
                fadeIn()
            case .showing:
                break
            case .fadeOut:
                self.fadeOut()
            }
        }
    }

    var observer: CFRunLoopObserver!
    var isNeedChange: Bool {
        return (prevCount <= 0 && count > 0) || (prevCount > 0 && count <= 0)
    }

    public init(withIn view: UIView) {
        self.masterView = view
    }

    func makeChange() {
        defer {
            self.prevCount = count
        }
        guard isNeedChange else { return }

        if count > 0 && self.state != .fadeIn {
            if self.state == .fadeOut {
                cancelFadeOut()
            }
            self.state = .fadeIn
        } else if count <= 0 && self.state != .fadeOut {
            if self.state == .fadeIn {
                cancelFadeIn()
            }
            self.state = .fadeOut
        }
    }

    /// show indictorView by increasing count
    /// - Parameter text: text to be shown
    public func show(_ text: String? = nil) {
        count += 1
        if count > 0 {
            slaveView.text = text
        }

//        if self.state == .fadeOut {
//            cancelFadeOut()
//        }
//
//        if self.state != .fadeIn {
//            self.state = .fadeIn
//        }
    }

    /// update text while not changing count
    /// - Parameter text: text to be shown
    public func update(_ text: String?) {
        slaveView.text = text
    }

    /// hide indciatorView by decreasing count
    public func hide() {
        count -= 1
//        if count <= 0 {
//            if self.state == .fadeIn {
//                cancelFadeIn()
//            }
//
//            if self.state != .fadeOut {
//                self.state = .fadeOut
//            }
//        }
    }

    ///  reset count, hide indicatorView
    public func reset() {
        count = 0
        slaveView.layer.removeAllAnimations()
        slaveView.removeFromSuperview()
    }

    private func fadeIn() {
        slaveView.layer.add(fadeInAnimation.animation, forKey: "fadeIn")
    }

    private func fadeOut() {
        slaveView.layer.add(fadeOutAnimation.animation, forKey: "fadeOut")
    }

    private func cancelFadeIn() {
        slaveView.layer.removeAnimation(forKey: "fadeIn")
//        slaveView.removeFromSuperview()
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
