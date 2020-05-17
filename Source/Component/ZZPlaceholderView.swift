//
//  ZZPlaceholderView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

public class ZZPlaceholderView: UIView {
    public static var globalStyle = Style()

    public struct Style {
        public var offset: CGPoint = .zero
        public var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        public var imageSize: CGSize?
        public var titleMarginTop: CGFloat = 20
        public var titleColor: UIColor = UIColor(hex: 0x7b888e)
        public var titleFont: UIFont = UIFont.systemFont(ofSize: 16)

        public var buttonSize: CGSize?
        public var configButton: ((UIButton) -> Void) = { button in
            button.titleLabel!.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(Theme.shared[.majorText], for: .normal)
        }

        public init() {}
    }

    public enum Image {
        /// UIActivityIndicator
        case indicator
        /// image
        case single(UIImage)
        /// animation images
        case multiple([UIImage], TimeInterval)
    }

    public struct DataSource {
        public var image: Image = .indicator
        public var title: String?
        public var attributedTitle: NSAttributedString?
        public var actionTitle: String?
        public var action: ((UIButton) -> Void)?
        public var pageAction: VoidClosure?
        public var style: Style?

        public init() {}
    }

    public var commonStyle: Style
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var actionButton: UIButton?

    let container = WKZLinearView()

    var action: ((UIButton) -> Void)?

    override init(frame: CGRect) {
        self.commonStyle = ZZPlaceholderView.globalStyle
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implement")
    }

    public func load(dataSource: DataSource) {
        let style = dataSource.style ?? self.commonStyle

        container.removeAllLinearViews()
        container.padding = style.padding
        container.snp.updateConstraints {
            $0.centerX.equalToSuperview().offset(style.offset.x)
            $0.centerY.equalToSuperview().offset(style.offset.y)
        }

        self.addImageView(dataSource, style: style)
        self.addTitleLabel(dataSource, style: style)
        self.addActionButton(dataSource, style: style)

        if let action = dataSource.pageAction {
            self.onTouch { _ in
                action()
            }
        } else {
            self.onTouch(nil)
        }
    }

    public func load(customView: UIView) {
        container.removeSubviews()

        container.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func doAction(_ sender: UIButton) {
        self.action?(sender)
    }

    func addImageView(_ dataSource: DataSource, style: Style) {
        switch dataSource.image {
        case .indicator:
            let activity = UIActivityIndicatorView(style: .whiteLarge)
            activity.color = UIColor(hex: 0x7b888e)
            activity.startAnimating()
            activity.zLinearLayout.justifyContent = .center
            container.addLinearView(activity)
        case .single(let image):
            let imageView = UIImageView()
            imageView.image = image
            imageView.zLinearLayout.justifyContent = .center
            container.addLinearView(imageView)
            self.imageView = imageView
        case .multiple(let images, let duration):
            let imageView = UIImageView()
            imageView.animationImages = images
            imageView.animationDuration = duration
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
            imageView.zLinearLayout.justifyContent = .center
            container.addLinearView(imageView)
            self.imageView = imageView
        }

        // 设置图片尺寸
        if let imageView = self.imageView, let size = style.imageSize {
            imageView.snp.makeConstraints { (make) in
                make.width.equalTo(size.width)
                make.height.equalTo(size.height)
            }
        }
    }

    func addTitleLabel(_ dataSource: DataSource, style: Style) {
        if dataSource.title != nil || dataSource.attributedTitle != nil {
            let titleLabel = UILabel()
            titleLabel.font = style.titleFont
            titleLabel.textColor = style.titleColor
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            container.addLinearView(titleLabel)
            if container.count > 0 {
                titleLabel.zLinearLayout.margin.top = style.titleMarginTop
            }
            self.titleLabel = titleLabel

            if let attr = dataSource.attributedTitle {
                titleLabel.attributedText = attr
            } else if let title = dataSource.title {
                titleLabel.text = title
            }
        }
    }

    func addActionButton(_ dataSource: DataSource, style: Style) {
        if let actionTitle = dataSource.actionTitle {
            let button = UIButton()
            button.setTitle(actionTitle, for: .normal)
            style.configButton(button)
            container.addLinearView(button)
            button.configureLinearStyle {
                $0.justifyContent = .center
                if self.container.count > 0 {
                    button.zLinearLayout.margin.top = 30
                }
                if let size = style.buttonSize {
                    $0.width = size.width
                    $0.height = .manual(Double(size.height))
                }
            }

            self.action = dataSource.action
            button.addTarget(self, action: #selector(doAction), for: .touchUpInside)

            self.actionButton = button
        }
    }

    func commonInitView() {
        self.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}
