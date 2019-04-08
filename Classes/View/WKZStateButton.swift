//
//  WKZStateButton.swift
//  collection
//
//  Created by william on 09/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class WKZStateButton: UIButton {
    var normalColor: UIColor {
        didSet {
            self.layer.backgroundColor = self.normalColor.cgColor
        }
    }
    var highlightedColor: UIColor
    var disabledColor: UIColor
    
    var percentCornerRadius: CGFloat?
    
    override open var isHighlighted: Bool {
        didSet {
            guard self.isEnabled else {
                return
            }
            self.layer.backgroundColor = self.isHighlighted ? self.highlightedColor.cgColor : self.normalColor.cgColor
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            self.layer.backgroundColor = self.isEnabled ? self.normalColor.cgColor : self.disabledColor.cgColor
        }
    }
    
    public init(color: UIColor, highlighted: UIColor? = nil, disabled: UIColor? = nil) {
        self.normalColor = color
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        if let h = highlighted {
            self.highlightedColor = h
        } else {
            self.highlightedColor = UIColor(red: r - 20.0 / 255, green: g - 20.0 / 255, blue: b - 20.0 / 255, alpha: 1)
        }
        
        if let d = disabled {
            self.disabledColor = d
        } else {
            self.disabledColor = UIColor(red: r * 0.5 + 0.5, green: g * 0.5 + 0.5, blue: b  * 0.5 + 0.5, alpha: 1)
        }
        
        super.init(frame: CGRect.zero)
        
        self.layer.backgroundColor = self.normalColor.cgColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if let percent = percentCornerRadius {
            layer.cornerRadius = bounds.height * percent
        }
    }
}


