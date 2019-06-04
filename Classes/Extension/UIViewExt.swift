//
//  UIView+WKZ.swift
//  Zhangzhilicai
//
//  Created by william on 11/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    /// 获取从属的viewController
    var controller: UIViewController? {
        var next = self.next

        while next != nil {
            if next!.isKind(of: UIViewController.self) {
                return (next as! UIViewController)
            }

            next = next!.next
        }

        return nil
    }
}

public extension UIView {
    /// 删除所有的subview
    @objc func removeSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }

    @discardableResult
    func addBottomLine(color: UIColor? = nil, left: CGFloat = 0, right: CGFloat = 0) -> UIView {
        let color = color ?? AppTheme.shared[.border]
        let line = UIView()
        line.backgroundColor = color
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-ONE_PX_ADJUST)
            make.left.equalToSuperview().offset(left)
            make.right.equalToSuperview().offset(-right)
            make.height.equalTo(ONE_PX)
        }

        return line
    }

    func addTopLine(color: UIColor? = nil, left: CGFloat = 0, right: CGFloat = 0) {
        let color = color ?? AppTheme.shared[.border]
        let line = UIView()
        line.backgroundColor = color
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(1-ONE_PX_ADJUST)
            make.left.equalToSuperview().offset(left)
            make.right.equalToSuperview().offset(-right)
            make.height.equalTo(ONE_PX)
        }
    }


//    func addBottomDashedLine(color: UIColor = themeColor[.Border,] left: CGFloat = 0, right: CGFloat = 0) {
//        let line = ZZDashLineView()
//        line.backedLayer.strokeColor = color.cgColor
//        self.addSubview(line)
//        line.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(0)
//            make.left.equalToSuperview().offset(left)
//            make.right.equalToSuperview().offset(-right)
//            make.height.equalTo(1)
//        }
//    }

    func successToast(_ message: String) {
        let view = ToastView(message: message, style: .success)
        self.showToast(view, position: .center)
    }

    @objc func popToast(_ message: String) {
        let view = ToastView(message: message)
        self.showToast(view)
    }
}

private var badgeLabelKey: UInt8 = 0
private var dotBadgeLayerKey: UInt8 = 0
public extension UIView {
    fileprivate var dotLayer: CALayer {
        var layer: CALayer! = objc_getAssociatedObject(self, &dotBadgeLayerKey) as? CALayer
        if layer == nil {
            layer = CALayer()
            layer.frame = CGRect(self.bounds.width - 4, 0, 6, 6)
            layer.cornerRadius = 3
            layer.backgroundColor = UIColor.red.cgColor
            layer.zPosition = 100

            self.layer.addSublayer(layer)

            objc_setAssociatedObject(self, &dotBadgeLayerKey, layer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return layer
    }

    func toggleDotBadge(_ show: Bool) {
        self.dotLayer.isHidden = !show
    }
//
//    fileprivate var badgeLabel: UILabel {
//        var label: UILabel! = objc_getAssociatedObject(self, &badgeLabelKey) as? UILabel
//        if label == nil {
//            label = UILabel()
//            label.frame = CGRect(self.bounds.width - 14, 0, 14, 14)
//            label.layer.cornerRadius = 7
//            label.layer.backgroundColor = UIColor.red.cgColor
//            label.zFontSize(10).zAlign(.center).zColor(UIColor.white)
//
//            self.addSubview(label)
//
//            objc_setAssociatedObject(self, &badgeLabelKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//
//        return label
//    }
//
//    @objc func setBadgeValue(_ count: Int) {
//        if count > 0 {
//            self.badgeLabel.isHidden = false
//            if count >= 100 {
//                self.badgeLabel.text = "..."
//            } else {
//                self.badgeLabel.text = String(count)
//            }
//        } else {
//            self.badgeLabel.isHidden = true
//        }
//    }
}

//extension UITabBarItem {
//    private var dotSuperview: UIView? {
//        if let tabBarView = self.value(forKeyPath: "_view") as? UIView {
//            for subview in tabBarView.subviews {
//                if NSStringFromClass(type(of: subview)) == "UITabBarSwappableImageView" {
//                    return subview
//                }
//            }
//        }
//
//        return nil
//    }
//
//    func toggleDotBadge(_ show: Bool) {
//        self.dotSuperview?.toggleDotBadge(show)
//    }
//}

private var touchHandlerKey: UInt8 = 0
public typealias UIViewTapAction = (UITapGestureRecognizer) -> Void
extension UIView {
    class TouchHandler {
        weak var owner: UIView?
        var action: UIViewTapAction
        var tap: UITapGestureRecognizer!

        init(target: UIView, action: @escaping UIViewTapAction) {
            self.owner = target
            self.action = action

            self.tap = UITapGestureRecognizer.init(target: self, action: #selector(onTaped(_:)))
            target.isUserInteractionEnabled = true
            target.addGestureRecognizer(self.tap)
        }

        deinit {
            self.owner?.removeGestureRecognizer(self.tap)
        }

        @objc func onTaped(_ tap: UITapGestureRecognizer) {
            self.action(tap)
        }
    }

    fileprivate var touchHandler: TouchHandler? {
        get {
            return objc_getAssociatedObject(self, &touchHandlerKey) as? TouchHandler
        }
        set {
            objc_setAssociatedObject(self, &touchHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc public func onTouch(_ action: UIViewTapAction?) {
        if let action = action {
            self.touchHandler = TouchHandler(target: self, action: action)
        } else {
            self.touchHandler = nil
        }
    }
}

// MARK: - animation
public extension UIView {
    @objc func shake() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, 0]
        animation.keyTimes = [NSNumber(value: 0), NSNumber(value: 1 / 6.0), NSNumber(value: 3 / 6.0), NSNumber(value: 5 / 6.0), NSNumber(value: 1)]
        animation.duration = 0.4
        animation.isAdditive = true
        self.layer.add(animation, forKey: "shake")
    }

    func success() {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: self.bounds.width - 15 - 20, y: (self.bounds.height - 20) / 2, width: 20, height: 20)
        layer.strokeColor = UIColor(hex: 0x5cb85c).cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 5
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        layer.lineJoin = CAShapeLayerLineJoin(rawValue: "round")
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 11))
        path.addLine(to: CGPoint(x: 8, y: 18))
        path.addLine(to: CGPoint(x: 20, y: 2))
        layer.path = path.cgPath
        self.layer.addSublayer(layer)

        layer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.3
        animation.fromValue = 0
        animation.toValue = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animation, forKey: "success")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            layer.removeFromSuperlayer()
        }
    }
}
