//
//  UITextField+WKZ.swift
//  Zhangzhi
//
//  Created by william on 18/07/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit

class TextFieldFilter: NSObject, UITextFieldDelegate {
    var condition: String?
    weak var originDelegate: UITextFieldDelegate?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text
        let result = text!.replacingCharacters(in: (text?.range(from: range))!, with: string)
        
        if result.count == 0 {
            return true
        }
        
        if let condition = self.condition {
            if condition.count > 0 && !result.isMatch(regex: condition) {
                return false
            }
        }
        
        if let origin = self.originDelegate {
            if origin .responds(to: #selector(textField(_:shouldChangeCharactersIn:replacementString:))) {
                return origin.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let origin = self.originDelegate else {
            return
        }
        if (origin.responds(to: #selector(textFieldDidBeginEditing(_:)))) {
            self.originDelegate?.textFieldDidBeginEditing?(textField)
        }
    }
}

private var textFieldFilterKey: UInt8 = 0
private var textFieldValidateKey: UInt8 = 0
public extension UITextField {
    // MARK: - 限制输入
    internal var filter: TextFieldFilter? {
        get {
            return objc_getAssociatedObject(self, &textFieldFilterKey) as? TextFieldFilter
        }
        set {
            objc_setAssociatedObject(self, &textFieldFilterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var filterCondition: String? {
        get {
            return self.filter?.condition
        }
        set {
            if self.filter == nil {
                self.filter = TextFieldFilter()
            }
            
            if self.delegate != nil && !(self.delegate! is TextFieldFilter) {
                self.filter!.originDelegate = self.delegate
            }
            
            self.delegate = self.filter
            self.filter!.condition = newValue
        }
    }
    
    func limit(length: Int, numberOnly: Bool) {
        let charactor = numberOnly ? "\\d" : "."

        self.filterCondition = "^\(charactor){0,\(length)}$"
    }
    
    func limit(regex: String) {
        self.filterCondition = regex
    }
    
    // MARK: - 验证规则
    var validator: TextFieldValidator? {
        get {
            return objc_getAssociatedObject(self, &textFieldValidateKey) as? TextFieldValidator
        }
        set {
            objc_setAssociatedObject(self, &textFieldValidateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public protocol TextFieldValidator {
    func validate() -> Bool
}
