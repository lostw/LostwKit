////
////  VersionManager.swift
////  HealthTaiZhou
////
////  Created by William on 2019/9/26.
////  Copyright © 2019 Wonders. All rights reserved.
////
//
//import UIKit
//import SwiftDate
//
//extension UserDefaults.Key {
//    static var skippedAppVersion: UserDefaults.Key<[String: Any]> { return .init(name: "appVersion.skip") }
//}
//
//public class VersionManager {
//    public struct Version {
//        /// 最新版本
//        public var version: String
//        /// 更新地址
//        public var link: String
//        /// 最低兼容版本
//        public var minVersion: String?
//        /// 更新内容
//        public var content: String?
//
//        public init(version: String, link: String) {
//            self.version = version
//            self.link = link
//        }
//
//        var isNewer: Bool {
//            return isVersion(version, olderThan: APP_VERSION)
//        }
//
//        var needForceUpdate: Bool {
//            if let forceVersion = minVersion,
//                isVersion(forceVersion, olderThan: APP_VERSION) {
//                return true
//            }
//
//            return false
//        }
//
//        var updateAddress: URL? {
//            return URL(string: link)
//        }
//    }
//
//    public enum TitleStrategy {
//        case version, fixed(String)
//    }
//
//    public var titleStrategy: TitleStrategy = .fixed("发现新版本")
//    public var placeholderContent: String = "有新的版本"
//    public var silenceDays: Int = 3
//
//    /// 检查版本
//    public func check(version: Version) {
//        self.prompt(with: version)
//    }
//
//    func prompt(with version: Version) {
//        guard let controller = UIApplication.shared.keyWindow?.rootViewController else {
//            return
//        }
//
//        guard version.isNewer else {
//            return
//        }
//
//        guard version.updateAddress != nil else {
//            return
//        }
//
//        if version.needForceUpdate {
//            self.showForcePrompt(version: version, from: controller)
//        } else {
//            self.showOptionalPrompt(version: version, from: controller)
//        }
//    }
//
//    func showForcePrompt(version: Version, from controller: UIViewController) {
//        controller.alert(title: promptTitle(for: version), message: version.content ?? placeholderContent, buttonTitles: ["立即更新"]) { _ in
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(version.updateAddress!, options: [:]) { _ in
//                    exit(0)
//                }
//            } else {
//                UIApplication.shared.openURL(version.updateAddress!)
//                DispatchQueue.main.async {
//                    exit(0)
//                }
//            }
//        }
//    }
//
//    func showOptionalPrompt(version: Version, from controller: UIViewController) {
//        if let skipInfo = UserDefaults[.skippedAppVersion] {
//            // 有效时间内，相同的版本号，可以跳过提示
//            if let time = skipInfo["expiredTime"] as? TimeInterval, time > Date().timeIntervalSince1970 {
//                if (skipInfo["version"] as? String) == version.version {
//                    return
//                }
//            }
//        }
//
//        controller.alertPrompt(title: promptTitle(for: version), message: version.content ?? placeholderContent, buttonTitles: ["立即更新", "暂不更新"]) {
//            if $0 {
//                UIApplication.shared.compatibleOpen(version.link)
//            } else {
//                var r = [String: Any]()
//                r["version"] = version.version
//                r["expiredTime"] = (Date() + self.silenceDays.days).timeIntervalSince1970
//                UserDefaults[.skippedAppVersion] = r
//            }
//        }
//    }
//
//    private func promptTitle(for version: Version) -> String {
//        switch self.titleStrategy {
//        case .version:
//            return version.version
//        case .fixed(let title):
//            return title
//        }
//    }
//}
