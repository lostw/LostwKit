//
//  ListDataSource.swift
//  Example
//
//  Created by William on 2020/3/17.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

public enum OperationType: String {
    case copy, paste, custom
}

public class SimpleListDataSource<Cell: UITableViewCell, Model>: NSObject, UITableViewDataSource, UITableViewDelegate {

    public typealias CellConfigureAction = (Cell, Model, IndexPath) -> Void
    public typealias CellActionCallback = (Model, IndexPath) -> Void

    public struct Operation {
        public var type: OperationType
        public var title: String
        public var action: (Model, IndexPath) -> Void

        public init(type: OperationType, title: String, action: @escaping (Model, IndexPath) -> Void) {
            self.type = type
            self.title = title
            self.action = action
        }
    }

    public var list: [Model] = []
    var tableView: UITableView

    public var onCellConfig: CellConfigureAction?
    public var onCellDelete: CellActionCallback?
    public var onCellSelect: CellActionCallback?

    public var allowedOperations: [Operation] = []

    public subscript(index: Int) -> Model { list[index] }

    public var isEmpty: Bool {
        return list.isEmpty
    }

    public required init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.register(Cell.self, forCellReuseIdentifier: defaultCellIdentifier)
    }

    public func bindData(_ list: [Model], append: Bool) {
        if append {
            self.list += list
        } else {
            self.list = list
        }
        self.tableView.reloadData()
    }

    // MARK: - UITableViewDelegate UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: indexPath) as! Cell

        guard indexPath.row < self.list.count else {
            return cell
        }

        self.onCellConfig?(cell, self.list[indexPath.row], indexPath)

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < self.list.count {
            self.onCellSelect?(self.list[indexPath.row], indexPath)
        }
    }

    //remove extra bottom line
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.onCellDelete != nil
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }


    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.onCellDelete?(self.list[indexPath.row], indexPath)
        }
    }

    // MARK: - menu
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return !self.allowedOperations.isEmpty
    }

    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        for operation in self.allowedOperations {
            if action.description.starts(with: operation.type.rawValue) {
                return true
            }
        }

        return false
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        for operation in self.allowedOperations {
            if action.description.starts(with: operation.type.rawValue) {
                operation.action(self.list[indexPath.row], indexPath)
                return
            }
        }
    }

    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            print(suggestedActions)
            // Create a UIAction for sharing
            let list = self.allowedOperations.map { operation in
                return UIAction(title: operation.title) { _ in
                    operation.action(self.list[indexPath.row], indexPath)
                }

            }

            // Create and return a UIMenu with the share action
            return UIMenu(title: "操作", children: list)
        })
    }
}
