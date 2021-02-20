//
//  Lostw.swift
//  LostwKit
//
//  Created by William on 2020/11/26.
//

import Foundation

public var lostw = Lostw.shared

public struct Lostw {
    public static let shared = Lostw()
    /// 应用基本信息
    public let app = App()

    public let folder = Folder()
    public lazy var diskCache = DiskFileManager.shared

    @available(iOS, deprecated, message: "do not use this")
    public var cacheURL: URL {
        return self.folder.cache
    }

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
