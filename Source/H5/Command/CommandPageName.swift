//
//  CommandPageName.swift
//  PowerBull
//
//  Created by William on 2020/1/12.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

/// name: String, 设置页面的名称
public class CommandPageName: H5Command {
    public init() {}
    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        context.vc?.pageName = data["name"] as? String
    }
}
