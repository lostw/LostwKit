//
//  UIViewControllerLifecycle.swift
//  HealthTaiZhou
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit

public typealias LifecycleClosure = (UIViewController, Bool) -> Void
public class ZZViewControllerLifecycle {
    public static let shared = ZZViewControllerLifecycle()

    var viewWillAppearQueue: [LifecycleClosure] = []
    var viewWillDisappearQueue: [LifecycleClosure] = []

    private var mutex = pthread_mutex_t()

    public init() {
        pthread_mutex_init(&(self.mutex), nil)
    }

    deinit {
        pthread_mutex_destroy(&(self.mutex))
    }

    public func injectViewWillAppear(_ action: @escaping LifecycleClosure) {
        pthread_mutex_trylock(&mutex)
        if viewWillAppearQueue.count == 0 {
            swizzleMethod(UIViewController.self, original: #selector(UIViewController.viewWillAppear(_:)), swizzled: #selector(UIViewController.zz_viewWillAppear(_:)))
        }

        viewWillAppearQueue.append(action)
        pthread_mutex_unlock(&mutex)
    }

    public func injectViewWillDisappear(_ action: @escaping LifecycleClosure) {
        pthread_mutex_trylock(&mutex)
        if viewWillDisappearQueue.count == 0 {
            swizzleMethod(UIViewController.self, original: #selector(UIViewController.viewWillDisappear(_:)), swizzled: #selector(UIViewController.zz_viewWillDisappear(_:)))
        }

        viewWillDisappearQueue.append(action)
        pthread_mutex_unlock(&mutex)
    }
}

extension UIViewController {
    @objc func zz_viewWillAppear(_ animated: Bool) {
        self.zz_viewWillAppear(animated)

        ZZViewControllerLifecycle.shared.viewWillAppearQueue.forEach {
            $0(self, animated)
        }
    }

    @objc func zz_viewWillDisappear(_ animated: Bool) {
        self.zz_viewWillDisappear(animated)

        ZZViewControllerLifecycle.shared.viewWillDisappearQueue.forEach {
            $0(self, animated)
        }
    }
}

public extension UIViewController {
    // MARK: - 导航栏
    private struct AssociatedKey {
        static var NavBarConfig: Int = 0
    }

    private class _NavBarConfig {
        var hidden: Bool = false
        var textColor: UIColor?
        var barColor: UIColor?
        var barStyle: UIBarStyle?
    }

    private var navBarConfig: _NavBarConfig {
        if let config = objc_getAssociatedObject(self, &AssociatedKey.NavBarConfig) as? _NavBarConfig {
            return config
        } else {
            let config = _NavBarConfig()
            objc_setAssociatedObject(self, &AssociatedKey.NavBarConfig, config, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return config
        }
    }

    /// 导航栏隐藏
    var navBarHidden: Bool {
        get { return navBarConfig.hidden }
        set { navBarConfig.hidden = newValue }
    }

    /// 导航栏标题颜色
    var navBarTextColor: UIColor? {
        get { return navBarConfig.textColor }
        set { navBarConfig.textColor = newValue }
    }

    /// 导航栏背景色
    var navBarColor: UIColor? {
        get { return navBarConfig.barColor }
        set { navBarConfig.barColor = newValue }
    }

    /// 导航栏风格
    var navBarStyle: UIBarStyle? {
        get { return navBarConfig.barStyle }
        set { navBarConfig.barStyle = newValue }
    }

    /// 通过UIViewController的属性去控制UINavigationBar, 结合到转场动画中平滑过渡
    static func enableNavBarControl() {
        swizzleMethod(UIViewController.self, original: #selector(willMove(toParent:)), swizzled: #selector(zz_willMove(toParent:)))
        ZZViewControllerLifecycle.shared.injectViewWillAppear {
            if let nav = $0.navigationController {
                if nav.viewControllers.contains($0) {
                    nav.setNavigationBarHidden($0.navBarHidden, animated: $1)
                }
            }

            $0.setupNaivationBar()
        }
    }

    @objc func zz_willMove(toParent: UIViewController?) {
        self.zz_willMove(toParent: toParent)
        if self == self.navigationController?.viewControllers.last,
            let count = self.navigationController?.viewControllers.count,
            count > 1 {
            self.navigationController!.viewControllers[count - 2].setupNaivationBar()
        }
    }

    @objc func animateNavigationBarColor() {
        transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.setupNaivationBar()
            }, completion: nil)
    }

    @objc func setupNaivationBar() {
        guard let nav = parent as? UINavigationController else {
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

    // MARK: - 返回按钮
    /// 使用不带文字的返回按钮
    static func enableSimpleBackItem() {
        ZZViewControllerLifecycle.shared.injectViewWillAppear { vc, _ in
            if vc.navigationItem.backBarButtonItem == nil {
                vc.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: vc, action: nil)
            }
        }
    }
}
