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
            ZLog.error("Invalid URL")
            return
        }

        open(url)
    }

    func dial(_ dialNumber: String) {
        compatibleOpen("tel:\(dialNumber)")
    }
}
