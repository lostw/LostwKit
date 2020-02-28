//
//  H5CommandNavBackAction.swift
//  HealthTaiZhou
//
//  Created by William on 2020/2/3.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

/// callback: String, H5页面注册的方法名
public class CommandNavBackAction: H5Command {
    weak var context: H5BridgeController?
    var callbackName: String?
    public init() {}

    public func execute(_ data: [String: Any], callback: H5CmdCallback?, context: H5BridgeController) {
        // 重置嵌入的返回动作
        context.currentPage.backAction = nil

        if let imageStr = data["image"] as? String,
            let imageData = Data(base64Encoded: imageStr),
            let image = UIImage(data: imageData, scale: 2) {
                self.callbackName = data["callbackName"] as? String
                self.context = context
                context.vc?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onButtonTouched))
        } else if let title = data["title"] as? String {
            self.callbackName = data["callbackName"] as? String
            self.context = context
            context.vc?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(onButtonTouched))
        } else {
            if let callbackName = data["callbackName"] as? String {
                context.currentPage.backAction = { [weak context] in
                    guard let context = context else { return }
                    context.callH5Func(named: callbackName, data: nil)
                }
            } else {
                // 没图片、没设置返回交互，不做任何处理
                context.vc?.navigationItem.leftBarButtonItem = nil
            }
        }

    }

    @objc func onButtonTouched() {
        if let callbackName = self.callbackName {
            self.context?.callH5Func(named: callbackName, data: nil)
        } else {
            if let h5Page = self.context?.vc {
                if h5Page.webView.canGoBack {
                    h5Page.webView.goBack()
                } else {
                    h5Page.navBack()
                }
            }

        }
    }
}
