//
//  ZZShapeView.swift
//  Zhangzhilicai
//
//  Created by william on 15/12/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class ZZShapeView: UIView {
    override open class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    public var backedLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }

    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}
