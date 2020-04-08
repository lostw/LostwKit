//
//  WKZListController.swift
//  collection
//
//  Created by william on 06/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class WKZTableCell: UITableViewCell {

    weak public var owner: UIViewController?

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.commonInitView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func commonInitView() {}

    open func bindData(_ data: Any, indexPath: IndexPath) {}
}

open class WKZCollectionCell: UICollectionViewCell {

    weak var owner: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func commonInitView() {}

    open func bindData(_ data: Any, indexPath: IndexPath) {
        fatalError("实现bindData方法")
    }
}

open class WKZListController: UIViewController {
    public var list = [Any]()
    public var newPaths = [IndexPath]()
    public var tableView = UITableView()
    public var page: Int = 0
    let cellIdentifier = defaultCellIdentifier
    public var sourceHandler: ((Int, @escaping PageableCompletionCallback) -> Void)?
    public var isError = false
    var parser: WKZViewModelParser?
    var entityClass: AnyClass?
    public var isDataFetched: Bool = false

    open var forPager: Bool {
        return true
    }
    public var noDataManager = WKZEmptySetManager()

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.commonInitView()
        self.noDataManager.masterView = self.tableView
        self.noDataManager.pageKey = .loading
    }

    open func commonInitView() {
        self.edgesForExtendedLayout = []

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

    }

    open func refresh() {
        self.refreshPage()
    }

    open func cancel() {

    }

    public func resetList() {
        self.list = []
        self.tableView.reloadData()
        self.noDataManager.visible = true
        self.noDataManager.setErrorText("")
        self.noDataManager.pageKey = .loading
        self.tableView.removePushRefresh()
    }

    open func didSelectItem(_ item: Any, at indexPath: IndexPath) {

    }

    public func registerCell(_ cellClass: AnyClass) {
        self.tableView.register(cellClass, forCellReuseIdentifier: self.cellIdentifier)
    }

    public func cellIdentifier(at indexPath: IndexPath) -> String {
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

    deinit {
        // iOS 10及以下需要主动释放，否则会闪退
        self.tableView.removePullRefresh()
        self.tableView.removePushRefresh()
    }
}

extension WKZListController: Pagable {

    @objc open func parseItem(_ item: Any) -> Any? {
        if let parser = self.parser {
            return parser.parse(item)
        }
        if item is NSNull {
            return nil
        }
        return item
    }

    public func toggleLoadMore(_ more: Bool) {
        if more {
            self.tableView.addPushRefresh { [weak self] in
                guard let self = self else { return }
                self.fetch()
            }
        } else {
            self.tableView.removePushRefresh()
        }
    }

    @objc open func didLoadData(at page: Int) {
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

extension WKZListController: UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath), for: indexPath)

        guard indexPath.row < self.list.count else {
            return cell
        }

        if let cell = cell as? WKZTableCell {
            cell.bindData(self.list[indexPath.row], indexPath: indexPath)
            cell.owner = self
        }
//        cell.textLabel?.text = self.list[indexPath.row]["title"]
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < self.list.count {
            self.didSelectItem(self.list[indexPath.row], at: indexPath)
        }
    }

    //remove extra bottom line
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
