//
//  WKZLabel.swift
//  Zhangzhi
//
//  Created by william on 07/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public class WKZLabel: UILabel {
    public var padding = UIEdgeInsets.zero

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds.inset(by: self.padding), limitedToNumberOfLines: numberOfLines)

        rect.origin.x -= self.padding.left
        rect.origin.y -= self.padding.top
        rect.size.width += self.padding.left + self.padding.right
        rect.size.height += self.padding.top + self.padding.bottom

        return rect
    }

    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.padding))
    }
}
