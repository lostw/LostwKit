//
//  Alert.swift
//  Alamofire
//
//  Created by William on 2020/8/20.
//

import Foundation

public class Alert {
    public static var defaultTitle: String?
    var title: String?
    var message: String?
    var style: UIAlertController.Style

    var actions: [UIAlertAction] = []

    public init(style: UIAlertController.Style = .alert) {
        self.title = Alert.defaultTitle
        self.style = style
    }

    public func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    public func message(_ message: String) -> Self {
        self.message = message
        return self
    }

    public func addAction(_ title: String, handler: (() -> Void)? = nil) -> Self {
        var finalHandler: ((UIAlertAction) -> Void)?
        if let handler = handler {
            finalHandler = { _ in
                handler()
            }
        }
        self.actions.append(UIAlertAction(title: title, style: .default, handler: finalHandler))
        return self
    }

    public func addCancel(_ title: String = "取消") -> Self {
        self.actions.append(UIAlertAction(title: title, style: .cancel, handler: nil))
        return self
    }

    public func show(in vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alertController.addAction(action)
        }
        alertController.modalPresentationStyle = .fullScreen
        vc.present(alertController, animated: true)
    }
}

extension Alert {
    public func asConfirm(_ title: String = "确定", handler: (() -> Void)? = nil) -> Self {
        addAction(title, handler: handler)
        return self
    }

    public func asPrompt(_ title: String = "确定", cancelTitle: String = "取消", handler: (() -> Void)? = nil) -> Self {
        addCancel(cancelTitle)
        addAction(title, handler: handler)
        return self
    }
}
