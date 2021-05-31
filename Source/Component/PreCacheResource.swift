//
//  PreCacheResource.swift
//  Example
//
//  Created by William on 2020/5/9.
//  Copyright © 2020 Wonders. All rights reserved.
//

import Foundation

public class PreCacheResource<Value: Codable> {
    public typealias DataProviderAction = (_ completion: @escaping ((Swift.Result<Value, Error>) -> Void)) -> Void


    private let key: String
    private let dataProvider: DataProviderAction

    private var onValueChanged: ((Value) -> Void)?
    private var isFetching: Bool = false
    private var cacheStrategy: CacheStrategy = .today
    private var fileURL: URL?
    private var fileKey: String {
        return "prefetch.data.\(key)"
    }

    public var resource: Value? {
        didSet {
            if let resource = self.resource {
                onValueChanged?(resource)
            }
        }
    }
    var lastFetchDate: Date? {
        didSet {
            UserDefaults.standard.set(lastFetchDate, forKey: "prefetch.time.\(key)")
        }
    }


    /// 初始化方法
    /// - Parameters:
    ///   - key: 资源唯一键
    ///   - fileURL: 在没有文件缓存时，若指定了fileURL，会尝试从该文件读取；若未指定，尝试查找bundle下的{key}.json
    ///   - cacheStrategy: 缓存策略，用于lazyFetch的时候校验缓存资源有效性
    ///   - dataProvider: 最新资源获取方式
    public init(key: String, localFile: URL? = nil, cacheStrategy: CacheStrategy = .today, dataProvider: @escaping DataProviderAction) {
        self.key = key
        self.cacheStrategy = cacheStrategy
        self.dataProvider = dataProvider
        if let url = localFile {
            self.fileURL = url
        } else {
            self.fileURL = Bundle.main.url(forResource: key, withExtension: "json")
        }

        self.load()
    }

    public func subscrible(on: @escaping ((Value) -> Void)) {
        self.onValueChanged = on
        if let resource = self.resource {
            on(resource)
        }
    }

    /// 使用dataProvider从网络加载数据
    public func sync() {
        if isFetching {
            return
        }

        isFetching = true
        self.dataProvider { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.save(value)
                self.lastFetchDate = Date()
                self.isFetching = false
            case .failure(let error):
                ZLog.error(error)
                self.isFetching = false
            }
        }
    }

    /// 使用dataProvider从网络加载数据，会先检查本地缓存的有效性
    public func lazySync() {
        if self.lastFetchDate == nil {
            self.lastFetchDate = UserDefaults.standard.object(forKey: "prefetch.time.\(key)") as? Date
        }

        // 检查时间有效性及资源有效性
        if self.lastFetchDate == nil || !self.cacheStrategy.isValid(date: self.lastFetchDate!) || self.resource == nil {
            self.sync()
        }
    }

    func load() {
        do {
            if let data = lostw.cache.diskCache.data(for: fileKey) {
                self.resource = try? JSONDecoder().decode(Value.self, from: data)
            }

            if self.resource == nil {
                if let url = self.fileURL {
                    let data = try Data(contentsOf: url)
                    self.resource = try JSONDecoder().decode(Value.self, from: data)
                }
            }
        } catch {
            ZLog.error(error.localizedDescription)
        }

    }

    func save(_ resource: Value) {
        self.resource = resource

        if let data = try? JSONEncoder().encode(resource) {
            lostw.cache.diskCache.setData(data, for: fileKey)
        }
    }
}
