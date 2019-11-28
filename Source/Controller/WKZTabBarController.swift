//
//  WKZTabbarController.swift
//  Zhangzhilicai
//
//  Created by william on 25/10/2017.
//Copyright © 2017 william. All rights reserved.
//

import UIKit

typealias WKZTabBarTouchAction = (Int) -> Void
protocol WKZTabBar where Self: UIView {
    var selectedIndex: Int {get set}
    var didTouchButtonCallback: WKZTabBarTouchAction? {get set}
}

public class WKZDefaultTabBar: UIView, WKZTabBar {
    private var barItems =  [UITabBarItem]()
    private var barButtons = [UIButton]()
    private var indicatorLine: UIView!
    private var titles = [String]()

    var highlightedColor = UIColor.black
    var animate = true
    override public var bounds: CGRect {
        didSet {
            self.updateLayout()
        }
    }
    var selectedIndex: Int = 0 {
        didSet {
            self.barButtons[oldValue].isSelected = false
            self.barButtons[selectedIndex].isSelected = true
            self.updateIndicatorPosition()
        }
    }
    var didTouchButtonCallback: WKZTabBarTouchAction?

    func loadBarItems(_ barItems: [UITabBarItem]) {
        self.barItems = barItems
        let titles = barItems.map { $0.title ?? "" }
        self.loadTitles(titles)
    }

    func loadTitles(_ titles: [String]) {
        self.titles = titles
        self.commonInitView()
    }

    @objc func onButtonTouched(_ sender: UIButton) {
        let idx = sender.tag - 10

        guard selectedIndex != idx else {
            return
        }

        selectedIndex = idx
        if let callback = didTouchButtonCallback {
            callback(idx)
        }
    }

    func updateIndicatorPosition() {
        let itemWidth = self.bounds.width / CGFloat(titles.count)
        var rect = indicatorLine.frame
        rect.origin.x = CGFloat(selectedIndex) * itemWidth + (itemWidth - rect.width) / 2

        if animate {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicatorLine.frame = rect
            })
        } else {
            self.indicatorLine.frame = rect
        }
    }

    func updateLayout() {
        guard self.titles.count > 0 else {
            return
        }
        let itemWidth = self.bounds.width / CGFloat(titles.count)
        let itemHeight = self.bounds.height
        for (idx, button) in barButtons.enumerated() {
            button.frame = CGRect(x: CGFloat(idx) * itemWidth, y: 0, width: itemWidth, height: itemHeight)
        }

        self.indicatorLine.frame = CGRect(x: itemWidth * 0.15 + CGFloat(selectedIndex) * itemWidth, y: self.bounds.height - 2, width: itemWidth * 0.7, height: 2)
    }

    func commonInitView() {
        self.backgroundColor = UIColor.white
        self.barButtons.removeAll()
        self.removeSubviews()

        let itemWidth = self.bounds.width / CGFloat(titles.count)
        let itemHeight = self.bounds.height
        for (idx, item) in titles.enumerated() {
            let button = UIButton()
            button.frame = CGRect(x: CGFloat(idx) * itemWidth, y: 0, width: itemWidth, height: itemHeight)
            button.setTitleColor(UIColor(hex: 0x555555), for: .normal)
            button.setTitleColor(highlightedColor, for: .selected)
            button.setTitle(item, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.addTarget(self, action: #selector(onButtonTouched(_:)), for: .touchUpInside)

            button.tag = 10 + idx

            self.addSubview(button)
            self.barButtons.append(button)
        }

        indicatorLine = UIView()
        indicatorLine.backgroundColor = highlightedColor
        indicatorLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(indicatorLine)
        indicatorLine.frame = CGRect(x: itemWidth * 0.15, y: self.bounds.height - 2, width: itemWidth, height: 2)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
    }
}

open class WKZTabBarController: UIViewController {
    public var tabView: UIView = UIView()
    public var tabBar: WKZDefaultTabBar = WKZDefaultTabBar()
    var contentView: UIView = UIView()
    public var controllers = [UIViewController]()

    public var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex < controllers.count else {
                selectedIndex = 0
                return
            }

            hideController(controllers[oldValue])
            displayController(selectedController)
        }
    }
    var selectedController: UIViewController {
        return controllers[selectedIndex]
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.commonInitView()
        // Do any additional setup after loading the view.
    }

    public func setupControllers(_ controllers: [UIViewController], selectedIndex: Int = 0) {
        self.controllers = controllers

        var items = [UITabBarItem]()
        controllers.forEach { (controller) in
            items.append(controller.tabBarItem)
        }

        self.tabBar.loadBarItems(items)

        self.tabBar.selectedIndex = selectedIndex
        self.selectedIndex = selectedIndex
        self.displayController(selectedController)
    }

    open func commonInitView() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = Theme.shared[.background]
        self.configureLayout()
    }

    func configureLayout() {
        self.view.addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        tabBar.highlightedColor = Theme.shared[.majorText]
        tabBar.didTouchButtonCallback = { [weak self] idx in
            guard let self = self else { return }
            self.selectedIndex = idx
        }
        tabView.addSubview(tabBar)
        tabBar.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(40)
        }

        tabView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(tabBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = [0, 40, tabView.bounds.width, tabView.bounds.height - 40]
    }

    open func displayController(_ c: UIViewController) {
        self.addChild(c)
        c.view.frame = contentView.bounds
        contentView.addSubview(c.view)
        c.didMove(toParent: self)
    }

    open func hideController(_ c: UIViewController) {
        guard c.parent != nil else {
            return
        }

        c.willMove(toParent: nil)
        c.view.removeFromSuperview()
        c.removeFromParent()
    }
}
