//
//  WKZAlertController.swift
//  Zhangzhilicai
//
//  Created by william on 01/12/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

private let ContentTop: CGFloat = 20
private let ContentWidth: CGFloat = 270
private let ContentPadding: CGFloat = 16

public typealias ZZAlertCallback = (Bool) -> Void

public class ZZAlertController: UIViewController {
    public enum Style {
        case confirm, prompt
    }
    public var titleLabel: UILabel!
    public var messageLabel: UILabel!

    public var titleText: String?
    public var message: String?
    public var style: Style = .confirm
    public var showClose: Bool = false
    public var buttonTitles: [String]?
    public var callback: ZZAlertCallback?

    var attributedMessage: NSAttributedString?

    public convenience init(title: String?, message: String?, style: Style = .confirm, buttonTitles: [String]? = nil, showClose: Bool = false, callback: ZZAlertCallback? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.titleText = title
        self.message = message
        self.style = style
        self.buttonTitles = buttonTitles
        self.showClose = showClose
        self.callback = callback
    }

//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.commonInitView()
        // Do any additional setup after loading the view.
    }

    @objc func onButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true) {
            if let callback = self.callback {
                callback(sender.tag == 101)
            }
        }
    }

    func commonInitView() {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)

        var height = ContentTop
        let labelWidth = ContentWidth - 2 * ContentPadding

        let view = UIView()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 10

        if showClose {
            let closeView = UIImageView(image: #imageLiteral(resourceName: "icon_pay_close"))
            closeView.contentMode = .center
            closeView.frame = CGRect(x: ContentWidth - 32, y: 2, width: 30, height: 30)
            view.addSubview(closeView)
            closeView.onTouch({ [unowned self](_) in
                self.dismiss(animated: true, completion: nil)
            })
        }

        if let title = self.titleText, !title.isEmpty {
            titleLabel = self.buildTitleLabel()
            titleLabel.text = title
            let size = titleLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
            titleLabel.frame = CGRect(x: ContentPadding, y: height, width: labelWidth, height: size.height)
            view.addSubview(titleLabel)

            height += size.height
        }

        if let message = self.message, !message.isEmpty {
            height += 8

            messageLabel = self.buildMessageLabel()
            messageLabel.text = message
            let size = messageLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
            messageLabel.frame = CGRect(x: ContentPadding, y: height, width: labelWidth, height: size.height)
            view.addSubview(messageLabel)

            height += size.height
        } else if let attr = self.attributedMessage {
            height += 8

            messageLabel = self.buildMessageLabel()
            messageLabel.attributedText = attr
            let size = messageLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
            messageLabel.frame = CGRect(x: ContentPadding, y: height, width: labelWidth, height: size.height)
            view.addSubview(messageLabel)

            height += size.height
        }

        height += ContentTop

        let line = UIView()
        line.frame = CGRect(x: 0, y: height, width: ContentWidth, height: 1)
        line.backgroundColor = UIColor(hex: 0xeeeeee)
        view.addSubview(line)
        height += 1

        var cancelTitle = "取消"
        var confirmTitle = "确认"
        if let buttonTitles = self.buttonTitles {
            if buttonTitles.count > 0 {
                confirmTitle = buttonTitles[0]
            }

            if buttonTitles.count > 1 {
                cancelTitle = buttonTitles[1]
            }
        }

        let wrapper = UIView()
        wrapper.frame = CGRect(x: 0, y: height, width: ContentWidth, height: 44)
        view.addSubview(wrapper)
        height += 44

        switch self.style {
        case .confirm:
            let confirmButton = self.buildButton()
            confirmButton.setTitle(confirmTitle, for: .normal)
            confirmButton.frame = wrapper.bounds
            confirmButton.tag = 101
            wrapper.addSubview(confirmButton)
        case .prompt:
            let width = wrapper.bounds.width / 2
            let height = wrapper.bounds.height

            let cancelButton = self.buildButton()
            cancelButton.setTitle(cancelTitle, for: .normal)
            cancelButton.frame = CGRect(x: width, y: 0, width: width, height: height)
            cancelButton.tag = 100
            cancelButton.setTitleColor(Theme.shared[.promptText], for: .normal)
            wrapper.addSubview(cancelButton)

            let confirmButton = self.buildButton()
            confirmButton.setTitle(confirmTitle, for: .normal)
            confirmButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
            confirmButton.tag = 101
            wrapper.addSubview(confirmButton)

            let seperator = UIView()
            seperator.frame = CGRect(x: width, y: 0, width: 1, height: height)
            seperator.backgroundColor = UIColor(hex: 0xeeeeee)
            wrapper.addSubview(seperator)
        }

        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(ContentWidth)
            make.height.equalTo(height)
        }
    }

    func buildButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor(hex: 0x007aff), for: .normal)
        button.addTarget(self, action: #selector(onButtonTouched(_:)), for: .touchUpInside)
        return button
    }

    func buildTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: ".SFUIText-Semibold", size: 17)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true

        return label
    }

    func buildMessageLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: ".SFUIText", size: 13)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }
}
