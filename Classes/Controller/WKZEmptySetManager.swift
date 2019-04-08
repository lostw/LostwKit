//
//  WKZEmptySetManage.swift
//  Zhangzhilicai
//
//  Created by william on 10/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

class WKZEmptySetManager {
    enum PageKey {
        case loading, empty, error, custom(String)
        
        var name: String {
            switch self {
            case .loading: return "loading"
            case .empty: return "empty"
            case .error: return "error"
            case .custom(let str): return str
            }
        }
        
        static func ==(lhs: PageKey, rhs: PageKey) -> Bool {
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
    var masterView: UIView! {
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
    
    var pageKey: PageKey = .loading {
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
    var visible = true {
        didSet {
            self.placeholderView.isHidden = !visible
        }
    }
   
    private var stateView = [String: ZZPlaceholderView.DataSource]()
    func addState(key: String, dataSource: ZZPlaceholderView.DataSource) {
        stateView[key] = dataSource
    }
    
    init() {
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
        error.images = ["icon_record_none"]
        error.title = "页面错误"
        self.addState(key: "error", dataSource: error)
    }
    
    func setEmptyText(_ text: String) {
        var dataSource = self.stateView["empty"]!
        dataSource.title = text
        self.addState(key: "empty", dataSource: dataSource)
    }
    
    func setErrorText(_ text: String) {
        var dataSource = self.stateView["error"]!
        dataSource.title = text
        self.addState(key: "error", dataSource: dataSource)
    }
}

