//
//  WKZLinearView.swift
//  collection
//
//  Created by william on 09/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public class WKZLinearLayout {
    public enum JustifyContent {
        case start, center, end, stretch
    }
    
    public enum Height {
        case auto //自约束
        case manual(FloatLiteralType) //手动设置高度
        case ratioToWidth(CGFloat) //与宽度成比例
        case containerHeight //使用容器设置的行高
    }
    
    public var height: Height = .auto
    public var disableTopLine = false
    public var inFlow = true       // 是否在布局流中
    public var justifyContent: JustifyContent = .stretch
    public var margin = UIEdgeInsets.zero
    public var isDirty = true  // 用于是否需要重新计算布局
}

extension WKZLinearLayout.Height: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .manual(value)
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .manual(Double(value))
    }
}



private var WKZLayoutKey: UInt8 = 0
extension UIView {
    public var zLinearLayout: WKZLinearLayout  {
        get {
            var layout = objc_getAssociatedObject(self, &WKZLayoutKey) as? WKZLinearLayout
            if layout == nil {
                layout = WKZLinearLayout()
                objc_setAssociatedObject(self, &WKZLayoutKey, layout, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return layout!
        }
    }
}

open class WKZLinearView: UIView {
    public var viewHeight: CGFloat = 44
    public var padding = UIEdgeInsets.zero
    public var ignoreFirstTopMargin = true
    public var asNormal = false
    public var enableSeperatorLine = false {
        didSet {
            self.lineLayer.isHidden = !enableSeperatorLine
            if enableSeperatorLine {
                self.setNeedsLayout()
            }
        }
    }
    public var lineColor = UIColor(hex: 0xe0e0e0) {
        didSet {
            self.lineLayer.strokeColor = self.lineColor.cgColor
        }
    }
    public var lineInsets = UIEdgeInsets.zero
    lazy fileprivate var lineLayer:CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = ONE_PX
        layer.strokeColor = self.lineColor.cgColor
        layer.zPosition = 100
        return layer
    }()
    
    fileprivate var views = [UIView]()
    
    public var count: Int {
        return views.count
    }
    public var hasLinearView: Bool {
        return !views.isEmpty
    }
    
    public func existLinearView(_ view: UIView) -> Bool {
        for innerView in self.views {
            if view == innerView {
                return true
            }
        }
        return false
    }
    
    public func viewAtIndex(_ index: Int) -> UIView {
        return self.views[index]
    }
    
    public func addLinearView(_ view: UIView, check: Bool = false) {
        if check {
            self.insertLinearView(view, at: self.views.count)
        } else {
            view.zLinearLayout.isDirty = true
            self.views.append(view)
            self.setNeedsUpdateConstraints()
        }
    }
    
    public func insertLinearView(_ view: UIView, at index: Int) {
        var idx = index
        view.zLinearLayout.isDirty = true
        
        if idx > self.views.count {
            idx = self.views.count
        }
        
        self.views.insert(view, at: idx)
        if idx == self.views.count - 1 {
            if idx != 0 {
                self.views[idx - 1].zLinearLayout.isDirty = true
            }
        } else {
            self.views[idx + 1].zLinearLayout.isDirty = true
        }
        
        self.setNeedsUpdateConstraints()
    }
    
    public func insertLinearView(_ view: UIView, before targetView: UIView) {
        for (idx, subview) in self.views.enumerated() {
            if targetView == subview {
                self.insertLinearView(view, at: idx)
                return
            }
        }
        
        self.addLinearView(view, check: true)
    }
    
    public func insertLinearView(_ view: UIView, after targetView: UIView) {
        for (idx, subview) in self.views.enumerated() {
            if targetView == subview {
                self.insertLinearView(view, at: idx+1)
                return
            }
        }
        
        self.addLinearView(view, check: true)
    }
    
    public func insertLinearView(_ views: [UIView], after targetView: UIView) {
        var i = self.views.count
        for (idx, subview) in self.views.enumerated() {
            if targetView == subview {
                i = idx + 1
                break
            }
        }
        
        for (idx, view) in views.enumerated() {
            self.insertLinearView(view, at: i + idx)
        }
    }
    
    public func removeLinearView(_ view: UIView) {
        if let idx = self.views.firstIndex(of: view) {
            self.removeLinearView(at: idx)
        }
    }
    
    public func removeLinearView(at index: Int) {
        guard index < self.views.count else {
            return
        }
        
        if index == self.views.count - 1 {
            self.views[index - 1].zLinearLayout.isDirty = true
        } else {
            self.views[index + 1].zLinearLayout.isDirty = true
        }
        
        self.views.remove(at: index)
        self.setNeedsUpdateConstraints()
    }
    
    public func removeAllLinearViews() {
        self.views.removeAll()
        self.setNeedsUpdateConstraints()
    }
    
    override open func updateConstraints() {
        defer {
            super.updateConstraints()
        }
        
        guard !self.asNormal else {
            return
        }
        //删除不存在self.views里面的subview
        for subview in self.subviews {
            if !self.views.contains(subview) {
                subview.removeFromSuperview()
            }
        }
        
        var prevView: UIView?
        for (idx, view) in self.views.enumerated() {
            if !view.zLinearLayout.isDirty {
                prevView = view
                continue
            }
            
            if view.superview == nil {
                self.addSubview(view)
            }
            
            view.snp.remakeConstraints({ (make) in
                let layout = view.zLinearLayout
                let margin = layout.margin
                
                if let prevView = prevView {
                    if margin.top < 0 && prevView.zLinearLayout.margin.bottom == 0 {
                        make.top.equalTo(prevView.snp.bottom).offset(margin.top)
                    } else {
                        make.top.equalTo(prevView.snp.bottom).offset(max(margin.top, prevView.zLinearLayout.margin.bottom))
                    }
                    
                } else {
                    if self.ignoreFirstTopMargin {
                        make.top.equalToSuperview().offset(self.padding.top)
                    } else {
                        make.top.equalToSuperview().offset(margin.top + self.padding.top)
                    }
                }
                
                switch(layout.justifyContent) {
                case .stretch:
                    make.left.equalToSuperview().offset(margin.left+self.padding.left)
                    make.right.equalToSuperview().offset(-margin.right-self.padding.right)
                case .start:
                    make.left.equalToSuperview().offset(margin.left+self.padding.left)
                case .center:
                    make.centerX.equalToSuperview()
                case .end:
                    make.right.equalToSuperview().offset(-margin.right-self.padding.right)
                }
                
                
                //默认view自约束高度
                switch layout.height {
                case .auto: break;
                case .containerHeight:
                    make.height.equalTo(self.viewHeight)
                case .manual(let value):
                    make.height.equalTo(value)
                case .ratioToWidth(let value):
                    make.height.equalTo(view.snp.width).multipliedBy(value)
                }
//                if layout.ratioToWidth > 0 {
//                    make.height.equalTo(view.snp.width).multipliedBy(layout.ratioToWidth)
//                } else if layout.height > 0 {
//                    make.height.equalTo(layout.height)
//                } else if layout.useContainerHeight {
//                    make.height.equalTo(self.viewHeight)
//                }
                
                if (idx == self.views.count - 1) {
                    make.bottom.equalToSuperview().offset(-margin.bottom-self.padding.bottom)
                }
            })
            
            view.zLinearLayout.isDirty = false
            
            if view.zLinearLayout.inFlow {
                prevView = view
            }
        }
    }
    
    public func reloadLinearView() {
        self.setNeedsUpdateConstraints()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if self.enableSeperatorLine {
            self.lineLayer.path = nil
            guard self.subviews.count > 1 else {
                return
            }
            
            if self.lineLayer.superlayer == nil {
                self.layer.addSublayer(self.lineLayer)
            }
            
            self.lineLayer.frame = self.bounds
            
            let path = UIBezierPath()
            var prev = self.views[0]
            for idx in 1..<self.views.count {
                let current = self.views[idx]
                
                if !current.zLinearLayout.disableTopLine {
                    if current.frame.origin.y - (prev.frame.origin.y + prev.frame.height) < 0.0001 {
                        path.move(to: CGPoint(x: self.lineInsets.left + self.padding.left, y: current.frame.origin.y - ONE_PX_ADJUST))
                        path.addLine(to: CGPoint(x: self.bounds.width - self.padding.right - self.lineInsets.right, y: current.frame.origin.y - ONE_PX_ADJUST))
                    }
                }
                
                prev = current
            }
            self.lineLayer.path = path.cgPath
        }
    }
}
