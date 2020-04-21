//
//  TableListController.swift
//  Example
//
//  Created by William on 2020/3/17.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

public struct TableListConfig {
    public var isEnableRefresh: Bool = true
    public var isEnableLoadMore: Bool = true
    public var isIndicatorNoData: Bool = false
}

open class TableListController<Cell: UITableViewCell, Model>: UIViewController {
    public var config: TableListConfig = TableListConfig()
    public var dataSource: SimpleListDataSource<Cell, Model>!
    public var dataProvider: ((_ page: Int, _ completion: @escaping ([Model], Bool, Error?) -> Void) -> Void)?

    public typealias DidFetchData = ([String: Any]) -> Void

//    public var list = [Model]()
    public let tableView = UITableView()
    public var page: Int = 0
    public var latestError: Error?

    public var didLoadTable: ((_ page: Int, _ more: Bool) -> Void)?
    public var didFetchData: DidFetchData?

    public var noDataManager = WKZEmptySetManager()

    deinit {
        // iOS 10及以下需要主动释放，否则会闪退
        self.tableView.removePullRefresh()
        self.tableView.removePushRefresh()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        commonInitView()
        self.dataSource = SimpleListDataSource<Cell, Model>(tableView: self.tableView)

        self.noDataManager.masterView = self.tableView
        self.noDataManager.pageKey = .loading
        self.noDataManager.setErrorRefreshAction { [weak self] in
            self?.noDataManager.pageKey = .loading
            self?.refresh()
        }
        // Do any additional setup after loading the view.
    }

    // MARK: - 数据加载
    public func refresh() {
        self.refreshPage()
    }

    public func reset() {
        self.page = 0
        self.dataSource.bindData([], append: false)
        self.noDataManager.visible = true
        self.noDataManager.setErrorText("")
        self.noDataManager.pageKey = .loading
        self.tableView.removePushRefresh()
    }

    public func cancel() {}

    private func fetch() {
        dataProvider?(self.page + 1, self.onDataFetched)
    }

    private func nextPage() {
        fetch()
    }

    private func refreshPage() {
        page = 0
        fetch()
    }

    func onDataFetched(_ comingList: [Model], _ hasMore: Bool, _ err: Error?) {
        self.latestError = err
        if let err = err {
            self.view.toast.error(err)

            // 如果此时没有数据，显示error页面
            if self.dataSource.isEmpty {
                self.noDataManager.setErrorText(err.localizedDescription)
                self.noDataManager.visible = true
                self.noDataManager.pageKey = .error
            }

            return
        }

        self.page += 1
        if !comingList.isEmpty {
            self.dataSource.bindData(comingList, append: self.page > 1)
        }
        self.didRecieveData(at: self.page, hasMore: hasMore)
        self.didLoadTable?(self.page, hasMore)
    }

    // MARK: - 状态更新
    open func didRecieveData(at page: Int, hasMore: Bool) {
        if self.dataSource.isEmpty {
            self.noDataManager.visible = true
            self.noDataManager.pageKey = .empty
        } else {
            self.noDataManager.visible = false
        }

        if page == 1 {
            self.tableView.stopPullRefreshEver()
        }

        self.toggleLoadMore(hasMore)
    }

    public func toggleLoadMore(_ more: Bool) {
        if more {
            self.tableView.addPushRefresh { [weak self] in
                guard let self = self else { return }
                self.fetch()
            }
            if self.config.isIndicatorNoData {
                self.tableView.stopPushRefreshEver(false)
            }
        } else {
            if self.config.isIndicatorNoData && !self.dataSource.isEmpty {
                self.tableView.addPushRefresh { [weak self] in
                    guard let self = self else { return }
                    self.fetch()
                }
                self.tableView.stopPushRefreshEver(true)
            } else {
                self.tableView.removePushRefresh()
            }
        }
    }


    // MARK: - 初始化控件
    open func commonInitView() {
        self.edgesForExtendedLayout = []

         configTableView()

        if self.config.isEnableRefresh {
            self.tableView.addPullRefresh { [weak self] in
                guard let self = self else { return }
                self.refresh()
            }
        }
    }

    func configTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = Theme.shared[.background]

        self.view.addSubview(self.tableView)
        self.tableView.estimatedRowHeight = 0
        //        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
    }


    public func addFixedBottomView(_ bottomView: UIView, animateIn: Bool = false) {
        self.view.addSubview(bottomView)

        if animateIn {
            bottomView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(isPhoneX() ? 83 : 49)
                make.bottom.equalToSuperview().offset(isPhoneX() ? 83 : 49)
            }

            self.view.layoutIfNeeded()

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    bottomView.snp.updateConstraints({ (make) in
                        make.bottom.equalToSuperview()
                    })

                    self.tableView.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().offset(isPhoneX() ? -83 : -49)
                    }

                    self.view.layoutIfNeeded()
                }, completion: nil)
            }

        } else {
            bottomView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(isPhoneX() ? 83 : 49)
            }

            self.tableView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(isPhoneX() ? -83 : -49)
            }
        }
    }
}
