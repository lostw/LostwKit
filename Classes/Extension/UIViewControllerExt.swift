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

public typealias ViewWillAppearInjection = (UIViewController) -> Void
public extension UIViewController {
    private struct AssociatedKey {
        static var kNavBarTextColorKey: Int = 0
        static var kNavBarColorKey: Int = 0
        static var kNavBarStyle: Int = 0
        static var navBarHidden: Int = 0
        static var globalWillAppear: Int = 0
    }

    static var globalWillAppearInjection: ViewWillAppearInjection? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.globalWillAppear) as? ViewWillAppearInjection
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.globalWillAppear, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    static func injectViewWillAppear(global: (ViewWillAppearInjection)? = nil) {
        self.globalWillAppearInjection = global

        swizzleMethod(UIViewController.self, original: #selector(viewWillAppear(_:)), swizzled: #selector(zz_viewWillAppear(_:)))
        swizzleMethod(UIViewController.self, original: #selector(willMove(toParent:)), swizzled: #selector(zz_willMove(toParent:)))
    }

    @objc func zz_viewWillAppear(_ animated: Bool) {
        self.zz_viewWillAppear(animated)

        UIViewController.globalWillAppearInjection?(self)

        if let nav = self.navigationController {
            if nav.viewControllers.contains(self) {
                nav.setNavigationBarHidden(self.navBarHidden ?? false, animated: animated)
            }
        }

        self.setupNaivationBar()
    }

    @objc func zz_willMove(toParent: UIViewController?) {
        self.zz_willMove(toParent: toParent)
        if self == self.navigationController?.viewControllers.last,
            let count = self.navigationController?.viewControllers.count,
            count > 1 {
            self.navigationController!.viewControllers[count - 2].setupNaivationBar()
        }
    }

    var navBarHidden: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.navBarHidden) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.navBarHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    var navBarTextColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.kNavBarTextColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.kNavBarTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var navBarColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.kNavBarColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.kNavBarColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var navBarStyle: UIBarStyle? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.kNavBarStyle) as? UIBarStyle
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.kNavBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func animateNavigationBarColor() {
        transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.setupNaivationBar()
            }, completion: nil)
    }

    @objc func setupNaivationBar() {
        guard let nav = navigationController else {
            return
        }

        nav.navigationBar.barTintColor = self.navBarColor ?? UINavigationBar.appearance().barTintColor
        nav.navigationBar.tintColor = self.navBarTextColor ?? UINavigationBar.appearance().tintColor
        nav.navigationBar.barStyle = self.navBarStyle ?? UINavigationBar.appearance().barStyle

        var attribute = UINavigationBar.appearance().titleTextAttributes ?? [:]
        if let textColor = self.navBarTextColor {
            attribute[.foregroundColor] = textColor
        }
        nav.navigationBar.titleTextAttributes = attribute
    }

    func useSimpleBackItem() {
        if self.navigationItem.backBarButtonItem == nil {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        }
    }
}
