//
//  Toast.swift
//  Toast-Swift
//
//  Copyright (c) 2015-2017 Charles Scalesse.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

/**
 Toast is a Swift extension that adds toast notifications to the `UIView` object class.
 It is intended to be simple, lightweight, and easy to use. Most toast notifications 
 can be triggered with a single line of code.
 
 The `makeToast` methods create a new view and then display it as toast.
 
 The `showToast` methods display any view as toast.
 
 */
public extension UIView {
    // MARK: - toast
    private class _ToastConfiguration {
        var duration: TimeInterval = 3
        var position: CGPoint = .zero
        var timer: Timer?
        var onCompletion: ((_ didTap: Bool) -> Void)?
    }

    private class _Toast {
        weak var container: UIView?
        var queue: [UIView] = []
        var activeToasts: [UIView] = []

        /**
         Displays any view as toast at a provided center point and duration. The completion closure
         executes when the toast view completes. `didTap` will be `true` if the toast view was
         dismissed from a tap.

         @param toast The view to be displayed as toast
         @param duration The notification duration
         @param point The toast's center point
         @param completion The completion block, executed after the toast view disappears.
         didTap will be `true` if the toast view was dismissed from a tap.
         */
        func show(_ view: UIView, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
            view._toastConfiguration.onCompletion = completion

            if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
                view._toastConfiguration.duration = duration
                view._toastConfiguration.position = point

                queue.append(view)
            } else {
                show(view, duration: duration, point: point)
            }
        }

        // MARK: - Private Show/Hide Methods
        private func show(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
            guard let container = self.container else { return }
            toast.center = point
            //        toast.alpha = 0.0
            toast.transform = CGAffineTransform.init(scaleX: 0, y: 0)

            if ToastManager.shared.isTapToDismissEnabled {
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleToastTapped(_:)))
                toast.addGestureRecognizer(recognizer)
                toast.isUserInteractionEnabled = true
                toast.isExclusiveTouch = true
            }

            activeToasts.append(toast)
            container.addSubview(toast)

            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                //            toast.alpha = 1.0
                toast.transform = .identity
            }, completion: { _ in
                let timer = Timer(timeInterval: duration, target: self, selector: #selector(self.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                toast._toastConfiguration.timer = timer
            })
        }

        func hideToast() {
            guard let view = activeToasts.first else { return }
            hideToast(toast: view)
        }

        func hideToast(toast: UIView, fromTap: Bool = false) {
            if let timer = toast._toastConfiguration.timer {
                timer.invalidate()
            }

            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0.0
            }, completion: { _ in
                toast.removeFromSuperview()
                if let idx = self.activeToasts.firstIndex(of: toast) {
                    self.activeToasts.remove(at: idx)
                }

                let configuration = toast._toastConfiguration
                configuration.onCompletion?(fromTap)

                if let nextToast = self.queue.first {
                    self.queue.remove(at: 0)
                    self.show(nextToast, duration: configuration.duration, point: configuration.position)
                }
            })
        }

        // MARK: - Events
        @objc
        private func toastTimerDidFinish(_ timer: Timer) {
            guard let toast = timer.userInfo as? UIView else { return }
            hideToast(toast: toast)
        }

        @objc
        private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
            guard let toast = recognizer.view else { return }
            hideToast(toast: toast, fromTap: true)
        }
    }

    private var _toast: _Toast {
        var obj = objc_getAssociatedObject(self, &ToastKeys.toast) as? _Toast
        if obj == nil {
            obj = _Toast()
            obj!.container = self
            objc_setAssociatedObject(self, &ToastKeys.toast, obj!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return obj!
    }

    private var _toastConfiguration: _ToastConfiguration {
        var obj = objc_getAssociatedObject(self, &ToastKeys.configuration) as? _ToastConfiguration
        if obj == nil {
            obj = _ToastConfiguration()
            objc_setAssociatedObject(self, &ToastKeys.configuration, obj!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return obj!
    }

    // MARK: - convience text Toast method
    func toast(_ message: String, style: ToastView.Style = .normal) {
        if UIApplication.shared.applicationState == .background {
            return
        }

        if message.isEmpty {
            return
        }

        let view = ToastView(message: message, style: style)
        self.showToast(view, position: .center)
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
        _toast.show(toast, duration: duration, point: point, completion: completion)
    }

    // MARK: - Hide Toast Methods

    /**
     Hides the active toast. If there are multiple toasts active in a view, this method
     hides the oldest toast (the first of the toasts to have been presented).

     @see `hideAllToasts()` to remove all active toasts from a view.

     @warning This method has no effect on activity toasts. Use `hideToastActivity` to
     hide activity toasts.

     */
    func hideToast() {
        _toast.hideToast()
    }

    /**
     Hides an active toast.

     @param toast The active toast view to dismiss. Any toast that is currently being displayed
     on the screen is considered active.

     @warning this does not clear a toast view that is currently waiting in the queue.
     */
    func hideToast(toast: UIView) {
        _toast.hideToast(toast: toast, fromTap: false)
    }

    /**
     Hides all toast views.

     @param includeActivity If `true`, toast activity will also be hidden. Default is `false`.
     @param clearQueue If `true`, removes all toast views from the queue. Default is `true`.
     */
    func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }

        _toast.activeToasts.forEach { hideToast(toast: $0) }

        if includeActivity {
            hideLoading()
        }
    }

    /**
     Removes all toast views from the queue. This has no effect on toast views that are
     active. Use `hideAllToasts(clearQueue:)` to hide the active toasts views and clear
     the queue.
     */
    func clearToastQueue() {
        _toast.queue.removeAll()
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

    /**
     Keys used for associated objects.
     */
    private struct ToastKeys {
        static var toast        = "com.toast-swift.toast"
        static var configuration        = "com.toast-swift.timer"
        static var indicator = "com.toast-swift.activityView"
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
}
