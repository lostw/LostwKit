//
//  TableListController.swift
//  Example
//
//  Created by William on 2020/3/17.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

public struct TableListConfig {
    /// 是否支持刷新
    public var isEnableRefresh: Bool = true
    /// 是否支持加载更多
    public var isEnableLoadMore: Bool = true
    /// 是否提示加载完所有数据：用于分页的情况
    public var isIndicatorNoData: Bool = false
}

open class TableListController<Cell: UITableViewCell, Model>: UIViewController {
    public typealias DataProvider = (_ page: Int, _ completion: @escaping ([Model], Bool, Error?) -> Void) -> Void
    public typealias DataProviderResult = (_ page: Int, _ completion: @escaping (Swift.Result<[Model], Error>, _ pageSize: Int) -> Void) -> Void

    public var config: TableListConfig = TableListConfig()
    public var dataSource: SimpleListDataSource<Cell, Model>!
    /// 数据源获取
    public var dataProvider: DataProvider?

    public let tableView = UITableView()
    public var page: Int = 0
    public var latestError: Error?

    public var didLoadTable: ((_ page: Int, _ more: Bool) -> Void)?

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

    /// 重置列表状态
    public func reset() {
        self.page = 0
        self.dataSource.bindData([], append: false)
        self.noDataManager.visible = true
        self.noDataManager.setErrorText("")
        self.noDataManager.pageKey = .loading
        self.tableView.removePushRefresh()
    }

    /// 需要子类自己实现请求的取消
    open func cancel() {}

    /// 返回Swift.Result的接口请求专供
    public func configDataProviderResult(_ provider: @escaping DataProviderResult) {
        self.dataProvider = { page, completion in
            let resultProvider: ((Swift.Result<[Model], Error>, Int) -> Void) = { result, pageSize in
                switch result {
                case .success(let list):
                    completion(list, pageSize <= list.count, nil)
                case .failure(let error):
                    completion([], false, error)
                }
            }
            provider(page, resultProvider)
        }
    }

    private func fetch() {
        cancel()
        dataProvider?(self.page + 1, self.onDataFetched)
    }

    /// 下一页
    private func nextPage() {
        fetch()
    }

    /// 刷新
    private func refreshPage() {
        page = 0
        fetch()
    }

    /// 数据源获取后的回调
    /// - Parameters:
    ///   - comingList: 列表
    ///   - hasMore: 是否还有下一页数据
    ///   - err: 错误
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

            self.tableView.stopPullRefreshEver()
            self.toggleLoadMore(false)
            return
        }

        self.page += 1
        self.dataSource.bindData(comingList, append: self.page > 1)

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

        DispatchQueue.main.async {
            self.toggleLoadMore(hasMore)
        }
    }

    public func toggleLoadMore(_ more: Bool) {
        // 恢复加载更多的状态
        self.tableView.stopPushRefreshEver(false)

        if more {
            self.tableView.addPushRefresh { [weak self] in
                guard let self = self else { return }
                self.fetch()
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
