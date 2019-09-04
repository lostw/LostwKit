//
//  UIViewController+WKZ.swift
//  collection
//
//  Created by william on 08/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit

public typealias AlertCallback = (Bool) -> Void
public enum AlertStyle {
    case alert, prompt
}

public struct NavConfig {
    public enum Animation {
        case `default`, none, fade
    }
    public var animationType: Animation = .default
    // 0: 正常push；
    // >0: 保留nav.viewControllers[0..<step], 然后加入新controller; 如果超过数组长度，当0处理
    // <0: 保留nav.viewControllers[0..<(count+step)], 然后加入新controller; 如果超过数组长度，清空数组后加入
    public var step = Int.max

    public init() {}

    public init(animationType: Animation, step: Int) {
        self.animationType = animationType
        self.step = step
    }
}

public extension UIViewController {
    func showController(_ controller: UIViewController, present: Bool = false, animated: Bool = true) {
        if present {
            self.present(controller, animated: animated, completion: nil)
        } else {
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: animated)
        }
    }

    func fadeInController(_ controller: UIViewController) {
        self.navToController(controller, config: NavConfig(animationType: .fade, step: Int.max))
    }

    func navReplaceToController(_ controller: UIViewController, animated: Bool = true) {
        self.navToController(controller, config: NavConfig(animationType: (animated ? .default : .none), step: -1))
    }

    func navToController(_ controller: UIViewController, config: NavConfig = NavConfig()) {
        guard let nav = self.navigationController else {
            return
        }
        controller.hidesBottomBarWhenPushed = true

        var index = config.step
        let count = nav.viewControllers.count
        if index >= count {
            switch config.animationType {
            case .default:
                nav.pushViewController(controller, animated: true)
            case .none:
                nav.pushViewController(controller, animated: false)
            case .fade:
                let tranition = CATransition()
                tranition.duration = 0.2
                tranition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                tranition.type = CATransitionType.fade
//                if !controller.fd_prefersNavigationBarHidden {
//                    nav.setNavigationBarHidden(false, animated: false)
//                }
                nav.view.layer.add(tranition, forKey: "fade")
                nav.pushViewController(controller, animated: false)
            }
            return
        } else if index < 0 {
            index = max(count + index, 0)
        }

        var controllers = [UIViewController]()
        for i in 0..<index {
            controllers.append(nav.viewControllers[i])
        }

        //加入新的controller
        controllers.append(controller)

        switch config.animationType {
        case .default:
            nav.setViewControllers(controllers, animated: true)
        case .none:
            nav.setViewControllers(controllers, animated: false)
        case .fade:
            let tranition = CATransition()
            tranition.duration = 0.2
            tranition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            tranition.type = CATransitionType.fade
//            if !controller.fd_prefersNavigationBarHidden {
//                nav.setNavigationBarHidden(false, animated: false)
//            }
            nav.view.layer.add(tranition, forKey: "fade")
            nav.setViewControllers(controllers, animated: false)
        }
    }

    /// 用于返回按钮事件绑定
    @objc func close() {
        self.dismiss(animated: true)
    }

    /// 用于返回按钮事件绑定
    @objc func pop() {
        self.navBack()
    }

    func navBack(step: Int = 1, delay: TimeInterval = 0) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                self._navBack(step: step)
            }
        } else {
            self._navBack(step: step)
        }
    }

    private func _navBack(step: Int) {
        if step <= 0 {
            return
        }
        if let nav = self.navigationController {
            let count = nav.viewControllers.count
            if step >= count {
                nav.popToRootViewController(animated: true)
            } else if step == 1 {
                nav.popViewController(animated: true)
            } else {
                let i = count - step - 1
                nav.popToViewController(nav.viewControllers[i], animated: true)
            }
        }
    }

    func alertConfirm(title: String? = "提示", message: String) {
        self.alert(title: title, message: message, buttonTitles: nil, style: .alert, callback: nil)
    }

    func alertPrompt(title: String = "提示", message: String, buttonTitles: [String]? = nil, callback: AlertCallback? = nil) {
        self.alert(title: title, message: message, buttonTitles: buttonTitles, style: .prompt, callback: callback)
    }

    func alert(title: String? = nil, message: String, buttonTitles: [String]? = nil, style: AlertStyle = .alert, callback: AlertCallback? = nil) {
        var confirmTitle = "确认"
        var cancelTitle = "取消"
        if let titles = buttonTitles {
            if titles.count > 0 {
                confirmTitle = titles[0]
            }

            if titles.count > 1 {
                cancelTitle = titles[1]
            }
        }

        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if style == .prompt {
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (_) in
                if let callback = callback {
                    callback(false)
                }
            })
            controller.addAction(cancel)
        }

        let confirm = UIAlertAction(title: confirmTitle, style: .default, handler: { (_) in
            if let callback = callback {
                callback(true)
            }
        })
        controller.addAction(confirm)

        self.present(controller, animated: true)
    }
}

public extension UIViewController {
    func translucentNavigationBar(_ flag: Bool) {
        if flag {
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        } else {
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        }
    }

    func topMostViewController() -> UIViewController? {
        if let tabbar = self as? UITabBarController {
            return tabbar.selectedViewController!.topMostViewController()
        } else if let nav = self as? UINavigationController {
            return nav.visibleViewController!.topMostViewController()
        } else if let p = self.presentedViewController {
            return p.topMostViewController()
        } else {
            return self
        }
    }

    func showRootViewController(at tab: Int) {
        var tabBarController: UITabBarController!
        if self.tabBarController == nil {
            tabBarController = (UIApplication.shared.keyWindow?.rootViewController as! UITabBarController)
            tabBarController.selectedIndex = tab
            (tabBarController.selectedViewController as! UINavigationController).popToRootViewController(animated: false)
        } else {
            tabBarController = self.tabBarController
            if let selected = tabBarController.selectedViewController as? UINavigationController {
                if tabBarController.selectedIndex == tab {
                    selected.popToRootViewController(animated: true)
                } else {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        if let controller = tabBarController.viewControllers![tab] as? UINavigationController {
                            controller.popToRootViewController(animated: false)
                        }

                        DispatchQueue.main.async {
                            tabBarController.selectedIndex = tab
                        }
                    })
                    selected.popToRootViewController(animated: true)
                    CATransaction.commit()
                }
            }
        }
    }
}

// MARK: - 返回按钮
public protocol UINavigationBack: UIViewController {
    func shouldGoBack() -> Bool
}

extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if self.viewControllers.count < (navigationBar.items?.count ?? 0) {
            return true
        }

        var shouldPop = true
        if let vc = self.topViewController as? UINavigationBack {
            shouldPop = vc.shouldGoBack()
        }

        if shouldPop {
            DispatchQueue.main.async {
                self.popViewController(animated: true)
            }
        }

        return false
    }
}
