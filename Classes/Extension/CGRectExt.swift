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
    
    static func make(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func rectForCenterSize(_ size: CGSize) -> CGRect {
        return CGRect(x: (self.width - size.width)/2,
                      y: (self.height - size.height)/2,
                      width: size.width,
                      height: size.height)
    }
}

public extension UIEdgeInsets {
    public static func make(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

public extension CGSize {
    static func make(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
}

public extension CGPoint {
    static func make(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}
