//
//  ZZGradientView.swift
//  Zhangzhilicai
//
//  Created by william on 15/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class ZZGradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public var backedLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
