//
//  CommandRoute.swift
//  Alamofire
//
//  Created by William on 2020/4/28.
//

import UIKit

public final class CommandRoute: H5Command {
    public init() {}
    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        context.vc?.bridgeController?.reload()
        context.vc?.resetNavigationBar()
    }
}
