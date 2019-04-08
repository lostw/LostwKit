//
//  ZZShapeView.swift
//  Zhangzhilicai
//
//  Created by william on 15/12/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

class ZZShapeView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    var backedLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}
