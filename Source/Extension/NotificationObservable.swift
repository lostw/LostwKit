//
//  NSObjectExt.swift
//  Zhangzhilicai
//
//  Created by william on 13/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public protocol NotificationObservable {
    /// 注册监听
    func onNotification(named name: Notification.Name, object: Any?, queue: OperationQueue?, using callback: @escaping (Notification) -> Void) -> NSObjectProtocol
    /// 关闭监听
    func offNotification(_ observer: NSObjectProtocol)
    /// 关闭所有监听
    func offAllNotification()
}

class ObserverManager: NSObject {
    var observers = [NSObjectProtocol]()

    func add(_ observer: NSObjectProtocol) {
        self.observers.append(observer)
    }

    func remove(_ observer: NSObjectProtocol) {
        for (idx, item) in self.observers.enumerated() {
            if item.isEqual(observer) {
                NotificationCenter.default.removeObserver(observer)
                self.observers.remove(at: idx)
                break
            }
        }
    }

    func removeAll() {
        for item in self.observers {
            NotificationCenter.default.removeObserver(item)
        }

        self.observers.removeAll()
    }

    deinit {
        self.removeAll()
    }
}

private var observerManagerKey: Int = 0
extension NotificationObservable {
    private var observeManager: ObserverManager {
        var manager = objc_getAssociatedObject(self, &observerManagerKey) as? ObserverManager
        if manager == nil {
            manager = ObserverManager()
            objc_setAssociatedObject(self, &observerManagerKey, manager!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return manager!
    }

    @discardableResult
    public func onNotification(named name: Notification.Name, object: Any? = nil, queue: OperationQueue? = nil, using callback: @escaping (Notification) -> Void) -> NSObjectProtocol {
        let observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: callback)
        self.observeManager.add(observer)

        return observer
    }

    public func offNotification(_ observer: NSObjectProtocol) {
        self.observeManager.remove(observer)
    }

    public func offAllNotification() {
        self.observeManager.removeAll()
    }
}

extension NSObject: NotificationObservable {}
