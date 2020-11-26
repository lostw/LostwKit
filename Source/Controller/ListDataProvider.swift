//
//  ListDataProvider.swift
//  Alamofire
//
//  Created by William on 2020/10/9.
//

import Foundation

public typealias DataProviderResult<Model> = ([Model], Bool, Error?) -> Void
public protocol ListDataProvider {
    associatedtype ProviderModel
    func loadData(at page: Int, onResult: @escaping DataProviderResult<ProviderModel>)
}

public typealias DataProviderAnyAction<Model> = (_ page: Int, _ completion: @escaping ([Model], Bool, Error?) -> Void) -> Void
public class AnyDataProvider<Model>: ListDataProvider {
    public typealias Model = ProviderModel

    let action: DataProviderAnyAction<Model>
    public init(action: @escaping DataProviderAnyAction<Model>) {
        self.action = action
    }

    public func loadData(at page: Int, onResult: @escaping DataProviderResult<Model>) {
        self.action(page, onResult)
    }
}

public typealias DataProviderResultAction<Model> = (_ page: Int, _ completion: @escaping (Swift.Result<[Model], Error>, _ hasMore: (Int) -> Bool) -> Void) -> Void
public class ResultDataProvider<Model>: ListDataProvider {
    public typealias Model = ProviderModel

    let action: DataProviderResultAction<Model>
    public init(action: @escaping DataProviderResultAction<Model>) {
        self.action = action
    }

    public func loadData(at page: Int, onResult: @escaping DataProviderResult<Model>) {
        self.action(page) { result, hasMore in
            switch result {
            case .success(let list):
                onResult(list, hasMore(list.count), nil)
            case .failure(let error):
                onResult([], false, error)
            }
        }
    }
}
