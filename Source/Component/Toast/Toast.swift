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

public class Toast {
    unowned var masterView: UIView
    var queue: [UIView] = []
    var activeToasts: [UIView] = []

    init(withIn view: UIView) {
        self.masterView = view
    }

    public func show(_ message: String, style: ToastView.Style = .normal, position: ToastPosition = ToastManager.shared.position) {
        if UIApplication.shared.applicationState == .background {
            return
        }

        if message.isEmpty {
            return
        }

        let view = ToastView(message: message, style: style)
        self.showToast(view, position: position)
    }

    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, completion: ((_ didTap: Bool) -> Void)? = nil) {
        let point = position.centerPoint(forToast: toast, inSuperview: self.masterView)
        show(toast, duration: duration, point: point, completion: completion)
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

    public func hide() {
        guard let view = activeToasts.first else { return }
        hide(toast: view)
    }

    public func hide(toast: UIView, fromTap: Bool = false) {
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

    public func hideAll(clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }

        activeToasts.forEach { hide(toast: $0) }
    }

    // MARK: - Private Show/Hide Methods
    private func show(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
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
        masterView.addSubview(toast)

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            //            toast.alpha = 1.0
            toast.transform = .identity
        }, completion: { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(self.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            toast._toastConfiguration.timer = timer
        })
    }

    /**
     Removes all toast views from the queue. This has no effect on toast views that are
     active. Use `hideAllToasts(clearQueue:)` to hide the active toasts views and clear
     the queue.
     */
    private func clearToastQueue() {
        self.queue.removeAll()
    }

    // MARK: - Events
    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hide(toast: toast)
    }

    @objc
    private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hide(toast: toast, fromTap: true)
    }
}
