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
}

extension H5PageControllerPlugin {
    func willLoadPage(link: String?) -> Bool {
        return true
    }
}
