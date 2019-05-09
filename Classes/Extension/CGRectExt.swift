//
//  RectExt.swift
//  Zhangzhilicai
//
//  Created by william on 13/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit
public extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }

    func rectForCenterSize(_ size: CGSize) -> CGRect {
        return CGRect(x: (self.width - size.width)/2,
                      y: (self.height - size.height)/2,
                      width: size.width,
                      height: size.height)
    }
}

public extension UIEdgeInsets {
    init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

extension UIEdgeInsets: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = CGFloat

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        var top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0
        if elements.count == 0 {

        } else if elements.count == 1 {
            top = elements[0]
            left = elements[0]
            bottom = elements[0]
            right = elements[0]
        } else if elements.count == 2 {
            top = elements[0]
            left = elements[1]
            bottom = elements[0]
            right = elements[1]
        } else if elements.count == 3 {
            top = elements[0]
            left = elements[1]
            bottom = elements[2]
            right = elements[1]
        } else {
            top = elements[0]
            left = elements[1]
            bottom = elements[2]
            right = elements[3]
        }

        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

public extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
}

extension CGSize: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = CGFloat

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        var width: CGFloat = 0, height: CGFloat = 0
        if elements.count >= 1 {
            width = elements[0]
        }

        if elements.count >= 2 {
            height = elements[1]
        }

        self.init(width: width, height: height)
    }
}

public extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }

    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}

extension CGPoint: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = CGFloat

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        var x: CGFloat = 0, y: CGFloat = 0
        if elements.count >= 1 {
            x = elements[0]
        }

        if elements.count >= 2 {
            y = elements[1]
        }

        self.init(x: x, y: y)
    }
}
