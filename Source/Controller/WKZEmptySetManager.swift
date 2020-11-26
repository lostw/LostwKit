//
//  WKZEmptySetManage.swift
//  Zhangzhilicai
//
//  Created by william on 10/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public class WKZEmptySetManager {
    public enum State {
        case hidden
        case loading
        case empty
        case error
        case custom(ZZPlaceholderView.DataSource)
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
                if masterView.isKind(of: UITableView.self) || masterView.isKind(of: UICollectionView.self) || masterView.isKind(of: UIScrollView.self) {
                    masterView.insertSubview(self.placeholderView, at: 0)
                } else {
                    masterView.addSubview(self.placeholderView)
                    self.placeholderView.snp.makeConstraints { (make) in
                        make.edges.equalToSuperview()
                    }
                }
            }
        }
    }

    public var state: State = .loading {
        didSet {
            switch state {
            case .hidden:
                self.placeholderView.isHidden = true
            case .loading:
                self.placeholderView.isHidden = false
                self.placeholderView.load(dataSource: loading)
            case .empty:
                self.placeholderView.isHidden = false
                self.placeholderView.load(dataSource: empty)
            case .error:
                self.placeholderView.isHidden = false
                self.placeholderView.load(dataSource: error)
            case .custom(let source):
                self.placeholderView.isHidden = false
                self.placeholderView.load(dataSource: source)
            }
        }
    }

    public var loading: ZZPlaceholderView.DataSource
    public var empty: ZZPlaceholderView.DataSource
    public var error: ZZPlaceholderView.DataSource

    public init() {
        self.loading = ZZPlaceholderView.DataSource(items: [
            PlaceholderComponent.indicator(nil),
            PlaceholderComponent.text("加载中...", nil)
        ], pageAction: nil)

        self.empty = ZZPlaceholderView.DataSource(items: [
            PlaceholderComponent.image(.single(UIImage.bundleImage(named: "icon_record_none")!), nil),
            PlaceholderComponent.text("暂无数据", nil)
        ], pageAction: nil)

        self.error = ZZPlaceholderView.DataSource(items: [
            PlaceholderComponent.image(.single(UIImage.bundleImage(named: "icon_record_fail")!), nil),
            PlaceholderComponent.attributedText("加载失败 点击重试".styled.make({
                $0.find(.text("点击重试"))?.color(Theme.shared[.majorText])}), nil)
        ], pageAction: nil)
    }

    public func setStyleoffset(_ offset: CGPoint) {
        self.placeholderView.commonStyle.offset = offset
    }

    /// 只作为默认页面的快捷方法
    public func setDefaultEmptyText(_ text: String) {
        self.empty.replaceItem(PlaceholderComponent.text(text, nil), at: 1)
    }

    public func setDefaultErrorText(_ text: String = "加载失败") {
        self.error.replaceItem(PlaceholderComponent.text(text, nil), at: 1)
    }

    public func setDefaultLoadingText(_ text: String) {
        self.loading.replaceItem(PlaceholderComponent.text(text, nil), at: 1)
    }

    public func setDefaultErrorRefreshAction(_ action: @escaping VoidClosure) {
        self.error.pageAction = action
    }
}
