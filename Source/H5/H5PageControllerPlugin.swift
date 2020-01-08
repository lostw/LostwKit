//
//  H5PageControllerPlugin.swift
//  Alamofire
//
//  Created by William on 2019/9/13.
//

import Foundation

public protocol H5PageControllerPlugin {
    var owner: H5PageController? {get set}
    func willLoadPage(link: String?) -> Bool
    func shouldProcessURL(_ url: URL) -> Bool
}

extension H5PageControllerPlugin {
    public func willLoadPage(link: String?) -> Bool {
        return true
    }

    public func shouldProcessURL(_ url: URL) -> Bool {
        return true
    }
}
