//
//  UIView+Toast.swift
//  Alamofire
//
//  Created by William on 2019/12/11.
//

import Foundation
/**
 Keys used for associated objects.
 */
struct ToastKeys {
    static var toast        = "com.toast-swift.toast"
    static var configuration        = "com.toast-swift.timer"
    static var indicator = "com.toast-swift.activityView"
}

public extension UIViewController {
    var activity: Indicator {
        return view.activity
    }

    var toast: Toast {
        return view.toast
    }
}

public extension UIView {
    // MARK: - toast
    internal class _ToastConfiguration {
        var duration: TimeInterval = 3
        var position: CGPoint = .zero
        var timer: Timer?
        var onCompletion: ((_ didTap: Bool) -> Void)?
    }

    var toast: Toast {
        var obj = objc_getAssociatedObject(self, &ToastKeys.toast) as? Toast
        if obj == nil {
            obj = Toast(withIn: self)
            objc_setAssociatedObject(self, &ToastKeys.toast, obj!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return obj!
    }

    // MARK: - convience text Toast method
    func toast(_ message: String, style: ToastView.Style = .normal) {
        self.toast.show(message, style: style)
    }

    /**
     Displays any view as toast at a provided position and duration. The completion closure
     executes when the toast view completes. `didTap` will be `true` if the toast view was
     dismissed from a tap.

     @param toast The view to be displayed as toast
     @param duration The notification duration
     @param position The toast's position
     @param completion The completion block, executed after the toast view disappears.
     didTap will be `true` if the toast view was dismissed from a tap.
     */
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, completion: ((_ didTap: Bool) -> Void)? = nil) {
        let point = position.centerPoint(forToast: toast, inSuperview: self)
        self.toast.show(toast, duration: duration, point: point, completion: completion)
    }

    // MARK: -
    func hideToast() {
        toast.hide()
    }

    /**
     Hides an active toast.

     @param toast The active toast view to dismiss. Any toast that is currently being displayed
     on the screen is considered active.

     @warning this does not clear a toast view that is currently waiting in the queue.
     */
    func hideToast(toast: UIView) {
        self.toast.hide(toast: toast, fromTap: false)
    }

    func hideAllToasts(clearQueue: Bool = true) {
        self.toast.hideAll()
    }

    // MARK: - indicator
    public var activity: Indicator {
        var obj = objc_getAssociatedObject(self, &ToastKeys.indicator) as? Indicator
        if obj == nil {
            obj = Indicator(withIn: self)
            objc_setAssociatedObject(self, &ToastKeys.indicator, obj!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return obj!
    }

    func loading(_ text: String? = nil) {
        self.activity.show(text)
    }

    /// 更新当前加载框的文本，不影响计数
    func loadingUpdate(_ text: String? = nil) {
        self.activity.update(text)
    }

    func hideLoading() {
        self.activity.hide()
    }

    func clearLoading() {
        self.activity.reset()
    }
}

extension UIView {
    var csSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }

    var _toastConfiguration: _ToastConfiguration {
        var obj = objc_getAssociatedObject(self, &ToastKeys.configuration) as? _ToastConfiguration
        if obj == nil {
            obj = _ToastConfiguration()
            objc_setAssociatedObject(self, &ToastKeys.configuration, obj!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return obj!
    }
}
