//
//  WKZEmptySetManage.swift
//  Zhangzhilicai
//
//  Created by william on 10/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public class WKZEmptySetManager {
    public enum PageKey {
        case loading, empty, error, custom(String)

        var name: String {
            switch self {
            case .loading: return "loading"
            case .empty: return "empty"
            case .error: return "error"
            case .custom(let str): return str
            }
        }

        static func == (lhs: PageKey, rhs: PageKey) -> Bool {
            return lhs.name == rhs.name
        }
    }

    private let placeholderView: ZZPlaceholderView = {
        let view = ZZPlaceholderView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    public var masterView: UIView! {
        didSet {
            if masterView != nil {
                if masterView.isKind(of: UITableView.self) || masterView.isKind(of: UICollectionView.self) {
                    masterView.insertSubview(self.placeholderView, at: 0)
                } else {
                    masterView.addSubview(self.placeholderView)
                }
            }
        }
    }

    public var pageKey: PageKey = .loading {
        didSet {
            guard let dataSource = self.stateView[pageKey.name] else {
               self.placeholderView.isHidden = true
                return
            }

            guard self.visible else {
                return
            }

            self.placeholderView.isHidden = false
            self.placeholderView.load(dataSource: dataSource)
        }
    }
    public var visible = true {
        didSet {
            self.placeholderView.isHidden = !visible
        }
    }

    private var stateView = [String: ZZPlaceholderView.DataSource]()
    public func addState(key: String, dataSource: ZZPlaceholderView.DataSource) {
        stateView[key] = dataSource
    }

    public init() {
        var loading = ZZPlaceholderView.DataSource()
//        loading.images = ["load1", "load2", "load3"]
        loading.indicator = true
        loading.title = "加载中..."
        self.addState(key: "loading", dataSource: loading)

        var empty = ZZPlaceholderView.DataSource()
        empty.images = ["icon_record_none"]
        empty.title = "暂无数据"
        self.addState(key: "empty", dataSource: empty)

        var error = ZZPlaceholderView.DataSource()
        error.images = ["icon_record_fail"]
        error.attributedTitle = "加载失败 点击重试".styled.make {
            $0.find(.text("点击重试"))?.color(AppTheme.shared[.majorText])
        }
        error.style.padding = [-20, 0, 4, 0]
        self.addState(key: "error", dataSource: error)
    }

    public func setEmptyText(_ text: String) {
        var dataSource = self.stateView["empty"]!
        dataSource.title = text
        self.addState(key: "empty", dataSource: dataSource)
    }

    public func setErrorText(_ text: String) {
        var dataSource = self.stateView["error"]!
        dataSource.title = text
        self.addState(key: "error", dataSource: dataSource)
    }

    public func setLoadingText(_ text: String) {
        var dataSource = self.stateView["loading"]!
        dataSource.title = text
        self.addState(key: "loading", dataSource: dataSource)
    }

    public func setErrorRefreshAction(_ action: @escaping VoidClosure) {
        var dataSource = self.stateView["error"]!
        dataSource.pageAction = action
        self.addState(key: "error", dataSource: dataSource)
    }
}
