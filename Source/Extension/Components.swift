//
//  Components.swift
//  Alamofire
//
//  Created by William on 2019/4/2.
//

import Foundation

public extension UIButton {
    static func primary(isRound: Bool = true) -> UIButton {
        let btn = WKZStateButton(color: Theme.shared[.primary], disabled: Theme.shared[.disabled])

        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        if isRound {
            btn.percentCornerRadius = 0.5
        }

        return btn
    }
}
