//
//  WKZListController.swift
//  collection
//
//  Created by william on 06/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public protocol ZZPagable: AnyObject {
    associatedtype M
    var list: [M] {get set}
    var page: Int {get set}

    var isDataFetched: Bool {get set}
    var dataProvider: ZZListDataProvider! {get set}

    func refreshPage()
    func nextPage()
    func fetch()
    func cancel()

    func parseItem(_ item: Any) -> M?
    func didLoadData(at page: Int)
    func toggleLoadMore(_ more: Bool)

}

public protocol ZZListDataProvider: AnyObject {
    var parameters: [String: Any] {get set}
    var onDataFetched: (([Any], Bool, Error?) -> Void)? {get set}
    func fetch(at page: Int)
    func configParameters(_ dict: [String: Any])
}

extension ZZListDataProvider {
    public func configParameters(_ dict: [String: Any]) {
        for (key, value) in dict {
            self.parameters[key] = value
        }
    }
}

extension ZZPagable {
    public func fetch() {
        dataProvider.fetch(at: self.page + 1)
    }

    public func nextPage() {
        fetch()
    }

    public func refreshPage() {
        page = 0
        isDataFetched = false
        fetch()
    }

    public func cancel() {}
}

open class ZZSimpleListController<C: UITableViewCell, Model: Mapable>: UIViewController, UITableViewDelegate, UITableViewDataSource, ZZPagable {
    public typealias M = Model

    public typealias ConfigureCellCallback = (C, M, IndexPath) -> Void
    public typealias CellItemCallback = (M, IndexPath) -> Void
    public typealias WillLoadTableCallback = () -> Void
    public typealias DidFetchData = ([String: Any]) -> Void
    public class ModelParser<T: Mapable> {
        func parse(_ item: [String: Any]) -> T? {
            return T.from(dict: item)
        }
    }

    public var parameters = [String: Any]()

    public var list = [M]()
    public let tableView = UITableView()
    public var page: Int = 0
    public var pageSize: Int = 15
    public let cellIdentifier = defaultCellIdentifier
    public var isError = false
    public var parser = ModelParser<M>()
    public var isDataFetched: Bool = false
    public var configCell: ConfigureCellCallback?
    public var didSelectItem: CellItemCallback?
    public var willLoadTable: WillLoadTableCallback?
    public var onDelete: CellItemCallback?
    public var didFetchData: DidFetchData?
    public var autoParse = true
    public var dataProvider: ZZListDataProvider! {
        didSet {
            setupSourceHandler()
        }
    }

    var requestType = 0

    var forPager: Bool {
        return true
    }
    var indicatorNoMoreData = false
    public var noDataManager = WKZEmptySetManager()

    deinit {
        // iOS 10及以下需要主动释放，否则会闪退
        self.tableView.removePullRefresh()
        self.tableView.removePushRefresh()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.commonInitView()
        self.noDataManager.masterView = self.tableView
        self.noDataManager.pageKey = .loading
        self.noDataManager.setErrorRefreshAction { [weak self] in
            self?.noDataManager.pageKey = .loading
            self?.refresh()
        }
    }

    open func commonInitView() {
        self.edgesForExtendedLayout = []

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = AppTheme.shared[.background]

        self.view.addSubview(self.tableView)
        self.tableView.estimatedRowHeight = 0
        //        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }

        if self.forPager {
            self.tableView.addPullRefresh { [weak self] in
                guard let self = self else { return }
                self.refresh()
            }
        }

        self.tableView.register(C.self, forCellReuseIdentifier: defaultCellIdentifier)
    }

    public func refresh() {
        self.refreshPage()
    }

    func registerCell(_ cellClass: AnyClass) {
        self.tableView.register(cellClass, forCellReuseIdentifier: self.cellIdentifier)
    }

    func cellIdentifier(at indexPath: IndexPath) -> String {
        return self.cellIdentifier
    }

    func setupSourceHandler() {
        guard let provider = self.dataProvider else { return }

        provider.onDataFetched = { [weak self] (comingList, hasMore, err) in
            guard let self = self else { return }

            if err == nil {
                self.isError = false
            } else {
                self.isError = true
                self.view.toast(err!.localizedDescription)
                self.noDataManager.setErrorText(err!.localizedDescription)
            }

            let list = comingList.compactMap { self.parseItem($0) }
            if self.page == 0 {
                self.list = list
            } else {
                self.list += list
            }
            self.page += 1

            self.didLoadData(at: self.page)
            self.toggleLoadMore(hasMore)
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

    public func resetList() {
        self.list = []
        self.tableView.reloadData()
        self.noDataManager.visible = true
        self.noDataManager.setErrorText("")
        self.noDataManager.pageKey = .loading
        self.tableView.removePushRefresh()
    }

    // MARK: - UITableViewDelegate UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath), for: indexPath)

        guard indexPath.row < self.list.count else {
            return cell
        }

        self.configCell?(cell as! C, self.list[indexPath.row], indexPath)

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < self.list.count {
            self.didSelectItem?(self.list[indexPath.row], indexPath)
        }
    }

    //remove extra bottom line
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.onDelete != nil
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.onDelete?(self.list[indexPath.row], indexPath)
        }
    }

    // MARK: - Pageable
    public func parseItem(_ item: Any) -> M? {

        if !autoParse {
            return item as? M
        }

        if let item = item as? [String: Any] {
            return parser.parse(item)
        }
        return nil
    }

    public func toggleLoadMore(_ more: Bool) {
        if more {
            self.tableView.addPushRefresh { [weak self] in
                guard let self = self else { return }
                self.fetch()
            }
            if self.indicatorNoMoreData {
                self.tableView.loadMoreView?.state = .pulling
            }
        } else {
            if self.indicatorNoMoreData && self.list.count > 0 {
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

    @objc open func didLoadData(at page: Int) {
        self.willLoadTable?()
        self.isDataFetched = true
        if isError {
            self.noDataManager.visible = true
            self.noDataManager.pageKey = .error
        } else {
            if self.list.isEmpty {
                self.noDataManager.visible = true
                self.noDataManager.pageKey = .empty
            } else {
                self.noDataManager.visible = false
            }
        }

        self.tableView.stopPullRefreshEver()
        self.tableView.stopPushRefreshEver()

        self.tableView.reloadData()
    }
}
