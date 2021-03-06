//
//  ToastView.swift
//  Zhangzhilicai
//
//  Created by william on 14/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public class ToastView: UIView {
    public enum Style {
        case normal, success
    }

    var titleLabel: UILabel?
    var messageLabel: UILabel?
    var iconView: UIImageView?

    init(title: String? = nil, message: String, style: Style = .normal) {
        super.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = 5
        self.layer.opacity = 0.8

        let messageLabel = UILabel()
        messageLabel.zText(message).zFontSize(16).zColor(UIColor.white).zLines(0)

        let maxWidth = UIScreen.main.bounds.width * 0.8
        let messageSize = messageLabel.sizeThatFits(CGSize(width: maxWidth, height: 1000))
        let viewWidth = messageSize.width + 16

        var height: CGFloat = 10

        if style == .success {
            let image = UIImage.bundleImage(named: "icon_toast_success")
            let iconView = UIImageView(image: image)
            var rect = CGRect(x: 0, y: 0, width: 23, height: 23)
            rect.origin.x = (viewWidth - iconView.bounds.width) / 2
            rect.origin.y = height
            iconView.frame = rect
            self.addSubview(iconView)

            self.iconView = iconView

            height += rect.size.height + 6
        }

        if let title = title {
            let label = UILabel()
            label.zText(title).zFontSize(16).zColor(UIColor.white).zLines(1)
            let size = label.sizeThatFits(CGSize(width: maxWidth, height: 1000))
            let rect = CGRect(x: (viewWidth - size.width)/2, y: height, width: size.width, height: size.height)
            label.frame = rect
            self.addSubview(label)

            self.titleLabel = label

            height += rect.size.height + 6
        }

        messageLabel.frame = CGRect(x: 8, y: height, width: messageSize.width, height: messageSize.height)
        self.addSubview(messageLabel)
        self.messageLabel = messageLabel

        height += messageSize.height + 10

        self.bounds = CGRect(x: 0, y: 0, width: viewWidth, height: height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
