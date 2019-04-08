//
//  WKZAttribute.swift
//  collection
//
//  Created by william on 12/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class WKZAttribute {
    var ranges = [Range<Int>]()
    var attrs = [NSAttributedString.Key: Any]()
    var paragraphStyle: NSMutableParagraphStyle  {
        get {
            var style: NSMutableParagraphStyle? = self.attrs[.paragraphStyle] as? NSMutableParagraphStyle
            if style == nil {
                style = NSMutableParagraphStyle()
                self.attrs[.paragraphStyle] = style
            }
            
            return style!
        }
    }
    
    init(range: Range<Int>) {
        self.ranges.append(range)
    }
    
    init(ranges: [Range<Int>]) {
        self.ranges = ranges
    }
    
    @discardableResult
    func index(_ idx: Int) -> Self {
        guard idx < ranges.count else {
            return self
        }
        
        self.ranges = [self.ranges[idx]]
        return self
    }

    @discardableResult
    func font(_ font: UIFont) -> WKZAttribute {
        self.attrs[NSAttributedString.Key.font] = font
        return self
    }
    
    @discardableResult
    func fontSize(_ fontSize: CGFloat) -> WKZAttribute {
        self.attrs[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: fontSize)
        return self
    }
    
    @discardableResult
    open func color(_ color: UIColor) -> WKZAttribute {
        self.attrs[NSAttributedString.Key.foregroundColor] = color
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) ->WKZAttribute {
        self.attrs[NSAttributedString.Key.backgroundColor] = color
        return self
    }
    
    @discardableResult
    func kern(_ length: Float) ->WKZAttribute {
        self.attrs[NSAttributedString.Key.kern] = length as AnyObject?
        return self
    }
    
    @discardableResult
    func strikethrough(_ style: NSUnderlineStyle) ->WKZAttribute {
        self.attrs[NSAttributedString.Key.strikethroughColor] = style as AnyObject?
        return self
    }
    
    @discardableResult
    func underline(_ style: NSUnderlineStyle) ->WKZAttribute {
        self.attrs[NSAttributedString.Key.underlineStyle] = style as AnyObject?
        return self
    }
    
    @discardableResult
    func lineSpacing(_ value: Float) -> WKZAttribute {
        self.paragraphStyle.lineSpacing = CGFloat(value)
        return self
    }
    
    @discardableResult
    func paragraphSpacing(_ value: Float) -> WKZAttribute {
        self.paragraphStyle.paragraphSpacing = CGFloat(value)
        return self
    }
    
    @discardableResult
    func maximumLineHeight(_ value: Float) -> WKZAttribute {
        self.paragraphStyle.maximumLineHeight = CGFloat(value)
        return self
    }
    
    @discardableResult
    func minimumLineHeight(_ value: Float) -> WKZAttribute {
        self.paragraphStyle.minimumLineHeight = CGFloat(value)
        return self
    }
    
    @discardableResult
    func headIndent(_ value: Float) -> WKZAttribute {
        self.paragraphStyle.headIndent = CGFloat(value)
        return self
    }
    
    @discardableResult
    func alignment(_ value: NSTextAlignment) -> WKZAttribute {
        self.paragraphStyle.alignment = value
        return self
    }
    
    @discardableResult
    func lineBreakMode(_ value: NSLineBreakMode) -> WKZAttribute {
        self.paragraphStyle.lineBreakMode = value
        return self
    }
}


