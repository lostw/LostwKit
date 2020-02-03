//
//  H5CommandNavBackAction.swift
//  HealthTaiZhou
//
//  Created by William on 2020/2/3.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

/// callback: String, H5页面注册的方法名
public class CommandNavBackAction: H5Command {
    public init() {}

    public func execute(_ data: [String : Any], callback: H5CmdCallback?, context: H5BridgeController) {
        let callbackName = data["callback"] as? String
        context.currentPage.backAction = { [weak context] in
            guard let context = context else { return }
            context.callH5Func(named: callbackName, data: nil)
        }
    }
}
