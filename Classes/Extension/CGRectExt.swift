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

public extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
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
