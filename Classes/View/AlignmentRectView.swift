//
//  AlignmentRectView.swift
//  HealthTaiZhou
//
//  Created by William on 2019/1/22.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit

open class AlignmentRectView: UIView {
    open var insets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    override open var alignmentRectInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return insets
        } else {
            return super.alignmentRectInsets
        }
    }
}
