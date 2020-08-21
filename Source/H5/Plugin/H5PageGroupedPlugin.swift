//
//  H5PageGroupedPlugin.swift
//  Alamofire
//
//  Created by William on 2020/8/6.
//

import Foundation

public class H5PageGroupedPlugin: H5PageControllerPlugin {
    weak public var page: H5PageController? {
        didSet {
            self.plugins.forEach {
                $0.page = self.page
            }
        }
    }

    var plugins = [H5PageControllerPlugin]()

    public init(plugins: [H5PageControllerPlugin]) {
        self.plugins = plugins
    }

    public func willLoadPage(link: String?) -> Bool {
        for plugin in plugins {
            if !plugin.willLoadPage(link: link) {
                return false
            }
        }
        return true
    }

    public func shouldProcessRequest(_ request: URLRequest) -> Bool {
        for plugin in plugins {
            if !plugin.shouldProcessRequest(request) {
                return false
            }
        }
        return true
    }

    public func didLoadPage() {
        for plugin in plugins {
            plugin.didLoadPage()
        }
    }
}
