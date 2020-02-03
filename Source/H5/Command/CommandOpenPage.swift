//
//  CommandOpenPage.swift
//  PowerBull
//
//  Created by William on 2020/1/12.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

/// url: String, 跳转的路径
/// name: String, 可选, 页面名称，用于程序追溯页面
/// eraseCount: Int, 可选、默认为0, 在当前的页面层级上先删除相应数量的页面，再打开新页面
/// isReplacePage: String[Deprected], 对应 eraseCount = 1
public class CommandOpenPage: H5Command {
    public init() {}
    public func execute(_ config: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        guard let h5Page = context.vc,
            let url = config["url"] as? String  else {
                return
        }

        var eraseCount = 0
        if let count = config["eraseCount"] as? Int {
            eraseCount = count
        } else {
            eraseCount = (config["isReplacePage"] as? String).intValue
        }
        let vc = h5Page.session.getH5Page(link: url)
        vc.pageName = config["name"] as? String
        context.vc?.asyncGetLocalStorage { info in
            vc.storageData = info

            if eraseCount > 0 {
                context.vc?.navToController(vc, config: NavConfig(animationType: .default, step: -eraseCount))
            } else {
                context.vc?.showController(vc)
            }
        }

    }
}
