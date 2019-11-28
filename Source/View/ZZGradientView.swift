//
//  ZZGradientView.swift
//  Zhangzhilicai
//
//  Created by william on 15/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class ZZGradientView: UIView {
    public enum Direction {
        case left, top, leftTop, rightTop
    }
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public var backedLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }

    public var direction: Direction = .left {
        didSet {
            switch direction {
            case .left:
                backedLayer.startPoint = [0, 0]
                backedLayer.endPoint = [1, 0]
            case .top:
                backedLayer.startPoint = [0, 0]
                backedLayer.endPoint = [0, 1]
            case .leftTop:
                backedLayer.startPoint = [0, 0]
                backedLayer.endPoint = [1, 1]
            case .rightTop:
                backedLayer.startPoint = [1, 1]
                backedLayer.endPoint = [0, 1]
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
