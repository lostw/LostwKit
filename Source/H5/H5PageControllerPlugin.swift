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
    func shouldProcessRequest(_ request: URLRequest) -> Bool
    func didLoadPage()
}

extension H5PageControllerPlugin {
    public func willLoadPage(link: String?) -> Bool {
        return true
    }

    public func shouldProcessRequest(_ request: URLRequest) -> Bool {
        return true
    }

    public func didLoadPage() {}
}
