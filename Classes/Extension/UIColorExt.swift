//
//  UIColor+WKZ.swift
//  collection
//
//  Created by william on 12/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
     convenience init (hex: Int32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0, green: CGFloat((hex >> 8) & 0xff) / 255.0, blue: CGFloat(hex & 0xff) / 255.0, alpha: alpha)
    }
}
