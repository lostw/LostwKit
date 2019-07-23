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
import ObjectiveC

/**
 Toast is a Swift extension that adds toast notifications to the `UIView` object class.
 It is intended to be simple, lightweight, and easy to use. Most toast notifications 
 can be triggered with a single line of code.
 
 The `makeToast` methods create a new view and then display it as toast.
 
 The `showToast` methods display any view as toast.
 
 */
public extension UIView {

    /**
     Keys used for associated objects.
     */
    private struct ToastKeys {
        static var timer        = "com.toast-swift.timer"
        static var duration     = "com.toast-swift.duration"
        static var point        = "com.toast-swift.point"
        static var completion   = "com.toast-swift.completion"
        static var activeToasts = "com.toast-swift.activeToasts"
        static var coverView = "com.toast-swift.coverView"
        static var activityView = "com.toast-swift.activityView"
        static var activityCount = "com.toast-swift.activityToasts.count"
        static var queue        = "com.toast-swift.queue"
    }

    /**
     Swift closures can't be directly associated with objects via the
     Objective-C runtime, so the (ugly) solution is to wrap them in a
     class that can be used with associated objects.
     */
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?

        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }

    private enum ToastError: Error {
        case missingParameters
    }

    private var activeToasts: NSMutableArray {
        if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToasts) as? NSMutableArray {
            return activeToasts
        } else {
            let activeToasts = NSMutableArray()
            objc_setAssociatedObject(self, &ToastKeys.activeToasts, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return activeToasts
        }
    }

    private var queue: NSMutableArray {
        if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
            return queue
        } else {
            let queue = NSMutableArray()
            objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return queue
        }
    }

    // MARK: - Show Toast Methods

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
        showToast(toast, duration: duration, point: point, completion: completion)
    }

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
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
        objc_setAssociatedObject(toast, &ToastKeys.completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
            objc_setAssociatedObject(toast, &ToastKeys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            queue.add(toast)
        } else {
            showToast(toast, duration: duration, point: point)
        }
    }

    // MARK: - convience text Toast method
    func toast(_ message: String, style: ToastView.Style = .normal) {
        let view = ToastView(message: message, style: style)
        self.showToast(view, position: .center)
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
        guard let activeToast = activeToasts.firstObject as? UIView else { return }
        hideToast(activeToast)
    }

    /**
     Hides an active toast.
     
     @param toast The active toast view to dismiss. Any toast that is currently being displayed
     on the screen is considered active.
     
     @warning this does not clear a toast view that is currently waiting in the queue.
     */
    func hideToast(_ toast: UIView) {
        guard activeToasts.contains(toast) else { return }
        hideToast(toast, fromTap: false)
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

        activeToasts.compactMap { $0 as? UIView }
                    .forEach { hideToast($0) }

        if includeActivity {
            hideIndicator()
        }
    }

    /**
     Removes all toast views from the queue. This has no effect on toast views that are
     active. Use `hideAllToasts(clearQueue:)` to hide the active toasts views and clear
     the queue.
     */
    func clearToastQueue() {
        queue.removeAllObjects()
    }

    // MARK: - Activity Methods
    private var activityCount: Int {
        get {
            return objc_getAssociatedObject(self, &ToastKeys.activityCount) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &ToastKeys.activityCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var activityView: (UIView & ToastActivityView)? {
        get {
            return objc_getAssociatedObject(self, &ToastKeys.activityView) as? (UIView & ToastActivityView)
        }
        set {
            objc_setAssociatedObject(self, &ToastKeys.activityView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /**
     Creates and displays a new toast activity indicator view at a specified position.
    
     @warning Only one toast activity indicator view can be presented per superview. Subsequent
     calls to `makeToastActivity(position:)` will be ignored until `hideToastActivity()` is called.
    
     @warning `makeToastActivity(position:)` works independently of the `showToast` methods. Toast
     activity views can be presented and dismissed while toast views are being displayed.
     `makeToastActivity(position:)` has no effect on the queueing behavior of the `showToast` methods.
    
     @param position The toast's position
     */

    func showIndicator(_ text: String) {
        self.showIndicator(loadingText: text)
    }

    @objc func showIndicator(loadingText: String? = nil) {
        self.activityCount += 1
        if self.activityCount > 0 {
            if self.activityView == nil {
                self.activityView = createToastActivityView()
                objc_setAssociatedObject(self, &ToastKeys.activityView, self.activityView!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            self.activityView!.setTitle(loadingText)

            let point = ToastPosition.center.centerPoint(forToast: self.activityView!, inSuperview: self)
            makeToastActivity(self.activityView!, point: point)
        }
    }

    func replaceIndicator(loadingText: String? = nil) {
        if self.activityCount > 0 {
            self.activityView?.setTitle(loadingText)
        }
    }

    /**
     Dismisses the active toast activity indicator view.
     */
    @objc func hideIndicator() {
        self.activityCount -= 1
        if self.activityCount <= 0 {
            if let view = self.activityView, view.superview != nil {
                UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                    view.alpha = 0.0
                }, completion: { _ in
                    view.removeFromSuperview()
                    self.isUserInteractionEnabled = true
                })
            }
        }
    }

    func hideAllIndicator() {
        self.activityCount = 0
        self.hideIndicator()
    }

    // MARK: - Private Activity Methods

    private func makeToastActivity(_ toast: (UIView & ToastActivityView), point: CGPoint) {
        guard toast.superview == nil else {
            return
        }
        toast.alpha = 0.0
        toast.center = point

//        objc_setAssociatedObject(self, &ToastKeys.activityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        self.isUserInteractionEnabled = false
        self.addSubview(toast)

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 1.0
        })
        toast.startAnimating()
    }

    private func createToastActivityView() -> (UIView & ToastActivityView) {
        let style = ToastManager.shared.style

        let activityView = ToastManager.shared.activityView ?? DefaultActivityView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        activityView.backgroundColor = style.activityBackgroundColor
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityView.layer.cornerRadius = style.cornerRadius

        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }

        activityView.activityColor = style.activityIndicatorColor
        activityView.startAnimating()

        return activityView
    }

    // MARK: - Private Show/Hide Methods

    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        toast.center = point
//        toast.alpha = 0.0
        toast.transform = CGAffineTransform.init(scaleX: 0, y: 0)

        if ToastManager.shared.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }

        activeToasts.add(toast)
        self.addSubview(toast)

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
//            toast.alpha = 1.0
            toast.transform = .identity
        }, completion: { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }

    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
            timer.invalidate()
        }

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }, completion: { _ in
            toast.removeFromSuperview()
            self.activeToasts.remove(toast)

            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                completion(fromTap)
            }

            if let nextToast = self.queue.first as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
            }
        })
    }

    // MARK: - Events

    @objc
    private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hideToast(toast, fromTap: true)
    }

    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast)
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
