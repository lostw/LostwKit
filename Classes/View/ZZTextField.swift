//
//  WKZTextField.swift
//  Zhangzhi
//
//  Created by william on 15/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

@objcMembers
class ZZTextField: UITextField {
    var gap: CGFloat = 0
    var disableAction = false
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).insetBy(dx: gap, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).insetBy(dx: gap, dy: 0)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if self.disableAction {
            if action == #selector(paste(_:)) {
                return false
            }
            
            if action == #selector(select(_:)) {
                return false
            }
            
            if action == #selector(selectAll(_:)) {
                return false
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
