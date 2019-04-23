//
//  NSObjectExt.swift
//  Zhangzhilicai
//
//  Created by william on 13/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

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
extension NSObject {
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

    func zUnObserveAll() {
        self.observeManager.removeAll()
    }
}

struct KeyValueInfo {
    var target: NSObject!
    var keyPath: String!
    var callback: KeyPathObservationCallback!
}

class KVOManager: NSObject {
    var observers = [KeyValueInfo]()

    func add(_ target: NSObject, for keyPath: String, callback: @escaping KeyPathObservationCallback) {
        let info = KeyValueInfo(target: target, keyPath: keyPath, callback: callback)
        info.target.addObserver(self, forKeyPath: info.keyPath, options: [.old, .new], context: nil)
        self.observers.append(info)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        for info in self.observers {
            if info.target == (object as! NSObject) && info.keyPath == keyPath {
                info.callback(change, object)
            }
        }
    }

    func remove(_ target: NSObject, for keyPath: String) {
        for (idx, info) in self.observers.enumerated() {
            if info.target == target && info.keyPath == keyPath {
                self.observers.remove(at: idx)

                return
            }
        }
    }

    func removeAll() {
        let infos = self.observers
        self.observers.removeAll()

        for info in infos {
            info.target.removeObserver(self, forKeyPath: info.keyPath, context: nil)
        }

    }

    deinit {
        print("deinit from keyvaluemanager")
        self.removeAll()
    }
}

private var keyValueManagerKey: Int = 0
public typealias KeyPathObservationCallback = ([NSKeyValueChangeKey: Any]?, Any?) -> Void
extension NSObject {
    private var keyValueManager: KVOManager {
        var manager = objc_getAssociatedObject(self, &keyValueManagerKey) as? KVOManager
        if manager == nil {
            manager = KVOManager()
            objc_setAssociatedObject(self, &keyValueManagerKey, manager!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return manager!
    }

    @objc public func zObserveKeyPath(_ target: NSObject, for keyPath: String, using callback: @escaping KeyPathObservationCallback) {
        self.keyValueManager.add(target, for: keyPath, callback: callback)
    }

    public func zUnObserveKeyPath(_ target: NSObject, for keyPath: String) {
        self.keyValueManager.remove(target, for: keyPath)
    }

    func zUnObserveAllKeyValues() {
        self.keyValueManager.removeAll()
    }

    /// KVO wrapper, execute callback immediately
    func zWatch(_ target: NSObject, for keyPath: String, using callback: @escaping KeyPathObservationCallback) {
        self.keyValueManager.add(target, for: keyPath, callback: callback)

        var info = [NSKeyValueChangeKey: Any]()
        info[.newKey] = target.value(forKeyPath: keyPath)
        callback(info, target)
    }

    func zUnWatch(_ target: NSObject, for keyPath: String) {
        self.keyValueManager.remove(target, for: keyPath)
    }
}
