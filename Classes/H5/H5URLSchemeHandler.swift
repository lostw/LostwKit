//
//  NYCustomURLSchemeHandler.swift
//  NYOpenH5Demo
//
//  Created by 陈良静 on 2019/7/30.
//  Copyright © 2019 陈良静. All rights reserved.
//

import Foundation
import WebKit
import Alamofire
import CoreServices
import SDWebImage

@available(iOS 11.0, *)
public class H5URLSchemeHandler: NSObject, WKURLSchemeHandler {
    /// http 管理
    lazy var httpSessionManager: SessionManager = {
        let manager = SessionManager.default
//        manager.responseSerializer.acceptableContentTypes = Set(arrayLiteral: "text/html", "application/json", "text/json", "text/javascript", "text/plain", "application/javascript", "text/css", "image/svg+xml", "application/font-woff2", "font/woff2", "application/octet-stream")

        return manager
    }()

    /// 防止 urlSchemeTask 实例释放了，又给他发消息导致崩溃
    var holdUrlSchemeTasks = [AnyHashable: Bool]()
    /// 资源缓存
    var resourceCache = H5ResourceCache()

    deinit {
        print("\(String(describing: self)) 销毁了")
    }

    // MARK: - WKURLSchemeHandler
    // 自定义拦截请求开始
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        holdUrlSchemeTasks[urlSchemeTask.description] = true

        let headers = urlSchemeTask.request.allHTTPHeaderFields
        guard let accept = headers?["Accept"] else { return }
        guard let url = urlSchemeTask.request.url else { return }

        if accept.contains("image") {
            // 图片
            let requestURL = self.recoverURL(url)

            SDWebImageManager.shared.loadImage(with: requestURL, options: SDWebImageOptions.retryFailed, progress: nil) { (image, data, _, _, _, _) in
                if let image = image {
                    if let data = data {
                        let mimeType = self.mimeType(pathExtension: requestURL.pathExtension)
                        self.successTask(urlSchemeTask, mimeType: mimeType, data: data)
                    } else {
                        if let data = image.jpegData(compressionQuality: 1) {
                            self.successTask(urlSchemeTask, mimeType: "image/jpeg", data: data)
                        }
                    }
                } else {
                    self.loadCache(for: urlSchemeTask)
                }
            }
        } else {
            loadCache(for: urlSchemeTask)
        }
    }

    /// 自定义请求结束时调用
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        holdUrlSchemeTasks[urlSchemeTask.description] = false
    }
}

// MARK: - privateFunc
@available(iOS 11.0, *)
extension H5URLSchemeHandler {
    private func cacheKey(for task: WKURLSchemeTask) -> String? {
        guard let url = task.request.url else {
            return nil
        }
        return cacheKey(for: url)
    }
    /// 生成缓存key
    private func cacheKey(for resourceURL: URL) -> String {
        var fileName = resourceURL.absoluteString
        fileName.replaceFirst(matching: "zzscheme(s)?://", with: "")
        let extensionName = resourceURL.pathExtension.isEmpty ? "html" : resourceURL.pathExtension

        return ZZCrypto.md5(fileName) + ".\(extensionName)"
    }

    private func recoverURL(_ url: URL) -> URL {
        var result = url.absoluteString
        result.replaceFirst(matching: "zzscheme", with: "http")
        return URL(string: result)!
    }

    private func mimeType(pathExtension: String?) -> String {
        guard let pathExtension = pathExtension else { return "application/octet-stream" }

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           pathExtension as NSString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() {
                return mimetype as String
            }
        }

        //文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
        return "application/octet-stream"
    }
}

// MARK: - resource load
@available(iOS 11.0, *)
extension H5URLSchemeHandler {
    /// 先尝试加载本地资源
    private func loadCache(for task: WKURLSchemeTask) {
        let url = task.request.url!
        let cacheKey = self.cacheKey(for: url)

        if resourceCache.contain(forKey: cacheKey) {
            guard let data = resourceCache.data(forKey: cacheKey) else {
                return
            }

            let mimeType = self.mimeType(pathExtension: url.pathExtension)
            successTask(task, mimeType: mimeType, data: data)

            return
        }

        loadRemote(for: task)
    }

    private func successTask(_ task: WKURLSchemeTask, mimeType: String, data: Data) {
        let response = URLResponse(url: task.request.url!, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: "utf-8")
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()

        ZLog.info("[h5Resource]\(task.request.url!.absoluteString)")
    }

    /// 加载服务器资源
    private func loadRemote(for task: WKURLSchemeTask) {
        let url = task.request.url!
        // 替换成https请求
        let requestURL = recoverURL(url)

        httpSessionManager.request(requestURL, method: .get).responseData { [weak self] in
            guard let self = self else { return }
            // urlSchemeTask 是否提前结束，结束了调用实例方法会崩溃
            if let isValid = self.holdUrlSchemeTasks[task.description] {
                if !isValid {
                    return
                }
            }

            switch $0.result {
            case .success(let data):
                task.didReceive($0.response!)
                task.didReceive(data)
                task.didFinish()

                if let headers = $0.response?.allHeaderFields as? [String: Any],
                    let contentType = headers["Content-Type"] as? String {
                    if !(contentType.starts(with: "image")) {
                        let cacheKey = self.cacheKey(for: url)
                        self.resourceCache.setData(data: data, forKey: cacheKey)
                    }
                }

            case .failure(let error):
                task.didFailWithError(error)
            }
        }
    }
}
