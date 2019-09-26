//
//  CollectionViewDataSource.swift
//  HealthTaiZhou
//
//  Created by William on 2019/9/26.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit

public class CollectionViewDataSource<Cell: UICollectionViewCell, Model>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public typealias CellConfiguration = (Cell, Model, IndexPath) -> Void
    public typealias CellSelection = (Model, IndexPath) -> Void

    var list: [Model] = []
    var collectionView: UICollectionView
    var onCellConfig: CellConfiguration
    public var onSelect: CellSelection?

    public init(collectionView: UICollectionView, configureCell: @escaping CellConfiguration) {
        self.onCellConfig = configureCell
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(Cell.self, forCellWithReuseIdentifier: defaultCellIdentifier)
    }

    public func load(_ list: [Model]) {
        self.list = list
        self.collectionView.reloadData()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellIdentifier, for: indexPath) as! Cell

        onCellConfig(cell, list[indexPath.row], indexPath)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = list[indexPath.row]
        onSelect?(model, indexPath)
    }
}
