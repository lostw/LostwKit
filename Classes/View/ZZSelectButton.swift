//
//  ZZSelectButton.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/9/17.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

class ZZSelectButton: UIButton {
    var selectedBackgroundColor: UIColor?
    private var originBackgroundColor: UIColor?
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if isSelected {
                originBackgroundColor = self.backgroundColor
                self.backgroundColor = selectedBackgroundColor
            } else {
                self.backgroundColor = originBackgroundColor
            }
        }
    }
}
