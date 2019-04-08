//
//  UIApplicationExt.swift
//  Alamofire
//
//  Created by William on 2019/4/2.
//

import Foundation

public extension UIApplication {
    func compatibleOpen(_ str: String) {
        guard let url = URL(string: str) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    func dial(_ dialNumber: String) {
        compatibleOpen("tel:\(dialNumber)")
    }
}
