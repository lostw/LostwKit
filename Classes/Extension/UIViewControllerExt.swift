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

    convenience public init(withParams params: Dictionary<String, Any>) {
        self.init()
        self.setValuesForKeys(params)
    }

    func showController(_ controller: UIViewController, present: Bool = false, animated: Bool = true) {
        if present {
            self.present(controller, animated: animated, completion: nil)
        } else {
            guard (self.navigationController != nil) else {
                return
            }

            controller.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(controller, animated: animated)
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

    @objc func close() {
        self.dismiss(animated: true)
    }

    @objc func pop() {
        self.navBack()
    }

    func navBack(delay: TimeInterval = 0) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func navBack(step: Int) {
        if step <= 0 {
            return
        }
        let count = self.navigationController!.viewControllers.count
        if step >= count {
            self.navigationController!.popToRootViewController(animated: true)
        } else {
            let i = count - step - 1
            self.navigationController?.popToViewController(self.navigationController!.viewControllers[i], animated: true)
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
            let cancel = UIAlertAction(title: cancelTitle, style: .default, handler: { (_) in
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

//    @objc func wkz_prompt(title: String?, message: String?, buttonTitles: [String]? = nil, showClose: Bool = false, callback: WKZAlertCallback? = nil) {
//        let controller = WKZAlertController(title: title, message: message, style: .prompt, buttonTitles: buttonTitles, showClose: showClose, callback: callback)
//        controller.modalPresentationStyle = .overCurrentContext
//        controller.modalTransitionStyle = .crossDissolve
//        self.definesPresentationContext = true
//
//        if self.presentingViewController == nil {
//            UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true)
//        } else {
//            self.present(controller, animated: true)
//        }
//    }
//
//    @objc func wkz_prompt(title: String?, attributedMessage: NSAttributedString?, buttonTitles: [String]? = nil, showClose: Bool = false, callback: WKZAlertCallback? = nil) {
//        let controller = WKZAlertController(title: title, message: nil, style: .prompt, buttonTitles: buttonTitles, showClose: showClose, callback: callback)
//        controller.attributedMessage = attributedMessage
//        controller.modalPresentationStyle = .overCurrentContext
//        controller.modalTransitionStyle = .crossDissolve
//        self.definesPresentationContext = true
//
//        if self.presentingViewController == nil {
//            UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true)
//        } else {
//            self.present(controller, animated: true)
//        }
//    }
}

extension UIViewController {
    func translucentNavigationBar(_ flag: Bool) {
        if flag {
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        } else {
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        }
    }
}
