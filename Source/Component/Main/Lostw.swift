//
//  Lostw.swift
//  LostwKit
//
//  Created by William on 2020/11/26.
//

import Foundation

var _lostw = Lostw.Inner()
public var lostw = Lostw.shared


final public class Lostw {
    class Inner {
        let folder = Folder()
    }
    public static let shared = Lostw()
    /// 应用基本信息
    public let app = App()

    public let folder = _lostw.folder
    /// 用于缓存
    public lazy var cache: Cache = Cache()
    /// 用户本地存储
    public lazy var diskStorage: Storage = DiskFileManager(root: _lostw.folder.persist.appendingPathComponent("files", isDirectory: true))
    /// 用户本地缓存
    public lazy var diskCache: Storage = DiskFileManager(root: _lostw.folder.cache.appendingPathComponent("files", isDirectory: true))

    init() {}
}

extension Lostw {
    public struct App {
        public var version: String
        public var build: String

        init() {
            version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
            build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        }
    }
}

extension Lostw {
    public struct Folder {
        static let kitFolderName = "LostwKit"
        public let cache: URL
        public let persist: URL

        init() {
            let fileManager = FileManager.default
            // swiftlint:disable force_try
            var cacheDir = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var doucumentDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            // swiftlint:enable force_try

            self.cache = cacheDir.appendingPathComponent(Self.kitFolderName, isDirectory: true)
            self.persist = doucumentDir.appendingPathComponent(Self.kitFolderName, isDirectory: true)

            self.cache.wrapped.createDirectory()
            self.persist.wrapped.createDirectory()
        }
    }
}
