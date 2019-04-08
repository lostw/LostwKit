//
//  Components.swift
//  Alamofire
//
//  Created by William on 2019/4/2.
//

import Foundation

public extension UIButton {
    static func primary() -> UIButton {
        let btn = WKZStateButton(color: AppTheme.shared[.primary])
        
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.percentCornerRadius = 0.5
        
        return btn
    }
    
    static func major() -> UIButton {
        let btn = WKZStateButton(color: AppTheme.shared[.major])
        
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.percentCornerRadius = 0.5
        
        return btn
    }
}
