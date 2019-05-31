//
//  WKZListController.swift
//  collection
//
//  Created by william on 06/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public typealias PageableCompletionCallback = ([Any], Bool) -> Void
public protocol Pagable: AnyObject {
    associatedtype M
    var list: [M] {get set}
    var page: Int {get set}

    var isDataFetched: Bool {get set}
    var sourceHandler: ((Int, @escaping PageableCompletionCallback) -> Void)? {get set}

    func refreshPage()
    func nextPage()
    func fetch()

    func parseItem(_ item: Any) -> M?
    func didLoadData(at page: Int)
    func toggleLoadMore(_ more: Bool)

}

extension Pagable {
    public func fetch() {
        if let handler = self.sourceHandler {
            handler(self.page + 1) { [weak self](comingList, hasMore) in
                guard let self = self else { return }
                self.isDataFetched = true

                if self.page == 0 {
                    self.list.removeAll()
                }

                self.list += comingList.compactMap { self.parseItem($0) }
                self.page += 1

                self.didLoadData(at: self.page)
                self.toggleLoadMore(hasMore)
            }
        }
    }

    public func nextPage() {
        fetch()
    }

    public func refreshPage() {
        page = 0
        isDataFetched = false
        fetch()
    }

}

open class ZZListController<C: UITableViewCell, Model: Mapable>: UIViewController, UITableViewDelegate, UITableViewDataSource, Pagable {
    public typealias M = Model

    public typealias ConfigureCellCallback = (C, M, IndexPath) -> Void
    public typealias DidSelectItemCallback = (M, IndexPath) -> Void
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
    public var sourceHandler: ((Int, @escaping PageableCompletionCallback) -> Void)?
    public var isError = false
    public var parser = ModelParser<M>()
    public var isDataFetched: Bool = false
    public var configCell: ConfigureCellCallback?
    public var didSelectItem: DidSelectItemCallback?
    public var willLoadTable: WillLoadTableCallback?
    public var didFetchData: DidFetchData?
    public var autoParse = true

    var requestType = 0

    var forPager: Bool {
        return true
    }
    var indicatorNoMoreData = false
    public var noDataManager = WKZEmptySetManager()

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.commonInitView()
        self.noDataManager.masterView = self.tableView
        self.noDataManager.pageKey = .loading
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
