//
//  WKZChained.swift
//  Zhangzhi
//
//  Created by william on 21/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult
    func zBgColor(_ color: UIColor) -> Self {
        self.layer.backgroundColor = color.cgColor
        return self
    }
    
    @discardableResult
    func zCornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
}

extension UILabel {
    @discardableResult
    public func zText(_ text: String) -> Self {
        self.text = text
        
        return self
    }
    
    @discardableResult
    public func zAlign(_ align: NSTextAlignment) -> Self {
        self.textAlignment = align
        
        return self
    }
    
    @discardableResult
    public func zColor(_ color: UIColor) -> Self {
        self.textColor = color
        
        return self
    }
    
    @discardableResult
    public func zFont(_ font: UIFont) -> Self {
        self.font = font
        
        return self
    }
    
    @discardableResult
    public func zFontSize(_ size: CGFloat) -> Self {
        self.font = UIFont.systemFont(ofSize: size)
        
        return self
    }
    
    @discardableResult
    public func zLines(_ number: Int) -> Self {
        self.numberOfLines = number
        
        return self
    }
}

private var buttonHandlerKey: Int = 0
extension UIButton {
    @discardableResult
    public func zText(_ text: String) -> Self {
        self.setTitle(text, for: .normal)
        
        return self
    }
    
    @discardableResult
    public func zAlign(_ align: NSTextAlignment) -> Self {
        self.titleLabel?.textAlignment = align
        
        return self
    }
    
    @discardableResult
    public func zColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        
        return self
    }
    
    @discardableResult
    public func zFont(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        
        return self
    }
    
    @discardableResult
    public func zFontSize(_ size: CGFloat) -> Self {
        self.titleLabel?.font = UIFont.systemFont(ofSize: size)
        
        return self
    }
    
    @discardableResult
    public func zLines(_ number: Int) -> Self {
        self.titleLabel?.numberOfLines = number
        
        return self
    }
    
    @discardableResult
    public func zBind(target: Any?, action: Selector) -> Self {
        self.addTarget(target, action: action, for: .touchUpInside)
        return self
    }
    
    @discardableResult
    public func zBind(touchHandler: (()->Void)?) -> Self {
        self.touchHandler = touchHandler
        self.addTarget(self, action: #selector(onTouched), for: .touchUpInside)
        return self
    }
    
    @objc private func onTouched() {
        self.touchHandler?()
    }
    
    private var touchHandler: (()->Void)? {
        get {
            return objc_getAssociatedObject(self, &buttonHandlerKey) as? ()->Void
        }
        set {
            objc_setAssociatedObject(self, &buttonHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @discardableResult
    func zImage(_ image: UIImage?) -> Self {
        self.setImage(image, for: .normal)
        return self
    }
}

