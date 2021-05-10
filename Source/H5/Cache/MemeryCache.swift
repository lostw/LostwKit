//
//  MemeryCache.swift
//  OpenH5Demo
//
//  Created by 陈良静 on 2019/7/29.
//  Copyright © 2019 陈良静. All rights reserved.
//

import Foundation

/*
 使用双链表（逻辑） + hashMap（存储） 实现 LRU 缓存淘汰。三个维度：缓存时长、缓存数量、缓存大小。增删改查都是 O(1) 时间复杂度
 1. 缓存新增：
     1. 将新的缓存节点插入到链表的头结点位置。
 2. 缓存删除：
    1. 根据缓存时长、缓存数量、缓存大小三个维度，从尾节点向前删除缓存
 3. 缓存查询：
    1. 缓存命中，将命中的缓存节点移动到头结点位置
 4. 缓存修改：
     1. 更新节点。
     2. 将节点移动到链表头部
 */
/// 链表节点
class LinkedNode {
    /// 链表前驱节点
    var prev: LinkedNode?
    /// 链表后继节点
    var next: LinkedNode?

    var key: AnyHashable
    var value: Any
    var cost: UInt = 0
    var time: TimeInterval = 0

    init(key: AnyHashable, value: Any) {
        self.key = key
        self.value = value
    }
}

/// 链表对象
class LinkedNodeMap {
    /// 实现链表的存储结构
    var dict = [AnyHashable: LinkedNode]()

    /// 链表节点总占得空间大小
    var totalCost: UInt = 0
    /// 链表节点的数量
    var totalCount: UInt {
        return UInt(dict.count)
    }

    /// 头结点
    var head: LinkedNode?

    /// 为节点
    var tail: LinkedNode?

    subscript(key: AnyHashable) -> Any? {
        get {
            object(for: key)
        }
        set {
            if let obj = newValue {
                setObject(obj, for: key)
            } else {
                removeObject(for: key)
            }
        }
    }

    func object(for key: AnyHashable) -> Any? {
        guard let node = dict[key] else {
            return nil
        }

        /// 更新访问时间、节点位置
        update(node)

        return node.value
    }

    func setObject(_ object: Any, for key: AnyHashable) {
        if let node = dict[key] {
            update(node, with: object)
        } else {
            let node = LinkedNode(key: key, value: object)
            node.cost = UInt(MemoryLayout.size(ofValue: object))
            node.time = CACurrentMediaTime()
            insert(node)
        }
    }

    func removeObject(for key: AnyHashable) {
        if let node = dict[key] {
            remove(node)
        }
    }

    /// 在头节点位置插入节点
    ///
    /// - Parameter node:
    func insert(_ node: LinkedNode) {
        add(node)
        if head != nil {
            node.next = head
            head!.prev = node
            head = node
        } else {
            // 链表为空
            head = node
            tail = node
        }
    }

    /// 将节点移动到头节点位置
    ///
    /// - Parameter node:
    func bringNodeToHead(_ node: LinkedNode) {
        // 已经是头节点，不做处理
        if head === node { return }

        if tail === node {
            // 尾节点的情况，需要重置尾节点指针
            tail = node.prev
            tail!.next = nil
        } else {
            node.next!.prev = node.prev
            node.prev!.next = node.next
        }

        node.next = head
        node.prev = nil
        head!.prev = node
        head = node
    }

    /// 删除指定节点
    ///
    /// - Parameter node:
    func remove(_ node: LinkedNode) {
        delete(node)

        if let next = node.next {
            next.prev = node.prev
        }
        if let prev = node.prev {
            prev.next = node.next
        }
        if head === node { head = node.next }
        if tail === node { tail = node.prev }
    }

    /// 删除尾节点
    func trimTail() {
        guard let node = tail else { return }

        delete(node)
        if let prev = node.prev {
            prev.next = nil
            tail = prev
        } else {
            // 尾节点没有前置节点，说明只有一个节点
            head = nil
            tail = nil
        }
    }

    func trimToLimit(countLimit: UInt, costLimit: UInt, ageLimit: TimeInterval) {
        if totalCount == 0 {
            return
        }

        if costLimit == 0 || costLimit == 0 || ageLimit <= 0 {
            removeAll()
            return
        }

        // 从尾部开始检查node是否满足要求
        let now = CACurrentMediaTime()
        var node = tail
        while let current = node, (totalCount > countLimit || totalCost > costLimit || (now - current.time) > ageLimit) {
            delete(current)
            node = current.prev
        }

        if node == nil {
            head = nil
            tail = nil
        } else {
            node!.next = nil
            tail = node
        }
    }

    /// 清空链表
    func removeAll() {
        totalCost = 0
        head = nil
        tail = nil
        dict.removeAll()
    }

    private func add(_ node: LinkedNode) {
        dict[node.key] = node
        totalCost += node.cost
    }

    private func update(_ node: LinkedNode, with object: Any? = nil) {
        if let object = object {
            let cost = UInt(MemoryLayout.size(ofValue: object))
            totalCost += cost - node.cost

            node.cost = cost
            node.value = object
        }

        node.time = CACurrentMediaTime()
        bringNodeToHead(node)
    }

    private func delete(_ node: LinkedNode) {
        dict[node.key] = nil
        totalCost -= node.cost
    }
}

/// 内存缓存
public class MemoryCache: Cacheable {
    public static let shared = MemoryCache()
    /// 缓存总数量
    public var totalCount: UInt {
        var result: UInt = 0
        queue.sync {
            result = self.linedMap.totalCount
        }
        return result
    }
    /// 缓存总大小
    public var totalCost: UInt {
        var result: UInt = 0
        queue.sync {
            result = self.linedMap.totalCost
        }
        return result
    }

    /// 缓存数量限制
    public var countLimit: UInt
    /// 缓存大小限制
    public var costLimit: UInt
    /// 缓存时长限制
    public var ageLimit: TimeInterval

    /// 自动清理缓存时间间隔
    public var autoTrimInterval: TimeInterval {
        didSet {
            if autoTrimInterval > 0 {
                trimRecursively()
            }
        }
    }

    private let queue: DispatchQueue
    /// 双链表对象
    private var linedMap: LinkedNodeMap

    // MARK: - lifeCycle
    init() {
        queue = DispatchQueue(label: "lostw-cache", attributes: .concurrent)

        linedMap = LinkedNodeMap()
        costLimit = UInt.max
        countLimit = UInt.max
        ageLimit = Double.greatestFiniteMagnitude
        autoTrimInterval = 0

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarningNotification), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        linedMap.removeAll()
    }

    // MARK: - notification
    // 收到内存警告
    @objc private func didReceiveMemoryWarningNotification() {
        removeAllObject()
    }
    // 进入后台
    @objc private func didEnterBackgroundNotification() {
        trim()
    }

    // MARK: - privateMethod
    // 定时器递归调用，在后台自动清理超出缓存
    private func trimRecursively() {
        guard autoTrimInterval > 0 else {
            return
        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: DispatchTime.now() + autoTrimInterval) {
            self.trim()
            self.trimRecursively()
        }
    }
}

// MARK: - Acccess 公共访问接口
extension MemoryCache {
    public func contain(forKey key: AnyHashable) -> Bool {
        var result: Bool = false
        queue.sync {
            result = self.linedMap.dict.contains(where: {$0.key == key})
        }
        return result
    }

    public func object(forKey key: AnyHashable) -> Any? {
        var result: Any?
        queue.sync {
            result = linedMap[key]
        }
        return result
    }

    public func setObject(_ object: Any, forKey key: AnyHashable, withCost cost: UInt) {
        queue.async(flags: .barrier) {
            self.linedMap[key] = object
        }
    }

    public func removeObject(forKey key: AnyHashable) {
        queue.async(flags: .barrier) {
            self.linedMap[key] = nil
        }
    }

    public func removeAllObject() {
        queue.async(flags: .barrier) {
            self.linedMap.removeAll()
        }
    }
}

// MARK: - trim 将缓存大小移除到规定大小
extension MemoryCache {
    public func trim() {
        queue.async(flags: .barrier) {
            self.linedMap.trimToLimit(countLimit: self.countLimit, costLimit: self.totalCost, ageLimit: self.ageLimit)
        }
    }

    public func trim(withCost cost: UInt) {

    }

    public func trim(withCount count: UInt) {

    }

    public func trim(withAge age: TimeInterval) {

    }
}
