//
//  ZZPlaceholderView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

public enum ImageType {
    /// image
    case single(UIImage)
    /// animation images
    case multiple([UIImage], TimeInterval)
}

public protocol PlaceholderItem {}
public typealias ComponentConfigure<T> = (T) -> Void

public enum PlaceholderComponent: PlaceholderItem {
    case text(String, ComponentConfigure<UILabel>?)
    case attributedText(NSAttributedString, ComponentConfigure<UILabel>?)
    case image(ImageType, ComponentConfigure<UIImageView>?)
    case button(String, ComponentConfigure<UIButton>?)
    case indicator(ComponentConfigure<UIActivityIndicatorView>?)
}

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

        public init() {}
    }

    public struct DataSource {
        public var items: [PlaceholderItem] = []
        public var pageAction: VoidClosure?

        public init(items: [PlaceholderItem], pageAction: VoidClosure?) {
            self.items = items
            self.pageAction = pageAction
        }

        public mutating func replaceItem(_ item: PlaceholderItem, at index: Int) {
            items[index] = item
        }
    }

    public var commonStyle: Style
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var actionButton: UIButton?

    let container = UIStackView()

    override init(frame: CGRect) {
        self.commonStyle = ZZPlaceholderView.globalStyle
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implement")
    }

    public func load(dataSource: DataSource) {
        let style = self.commonStyle

        container.subviews.forEach {
            $0.removeFromSuperview()
            container.removeArrangedSubview($0)
        }
        container.snp.updateConstraints {
            $0.centerX.equalToSuperview().offset(style.offset.x)
            $0.centerY.equalToSuperview().offset(style.offset.y)
        }

        for item in dataSource.items {
            if let item = item as? PlaceholderComponent {
                switch item {
                case .text(let str, let block):
                    let label = buildLabel(style: style)
                    label.text = str
                    block?(label)
                    container.addArrangedSubview(label)
                case .attributedText(let attrStr, let block):
                    let label = buildLabel(style: style)
                    label.attributedText = attrStr
                    block?(label)
                    container.addArrangedSubview(label)
                case .indicator(let block):
                    let activity = UIActivityIndicatorView(style: .whiteLarge)
                    activity.color = UIColor(hex: 0x7b888e)
                    activity.startAnimating()
                    block?(activity)
                    container.addArrangedSubview(activity)
                case .image(let type, let block):
                    let imageView = buildImageView(type, style: style)
                    block?(imageView)
                    container.addArrangedSubview(imageView)
                case .button(let str, let block):
                    let button = buildButton(str, style: style)
                    block?(button)
                    container.addArrangedSubview(button)
                }
            }
        }

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

    func buildImageView(_ type: ImageType, style: Style) -> UIImageView {
        switch type {
        case .single(let image):
            let imageView = UIImageView()
            imageView.image = image
            imageView.zLinearLayout.justifyContent = .center
            return imageView
        case .multiple(let images, let duration):
            let imageView = UIImageView()
            imageView.animationImages = images
            imageView.animationDuration = duration
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
            imageView.zLinearLayout.justifyContent = .center
            return imageView
        }

        // 设置图片尺寸
        if let imageView = self.imageView, let size = style.imageSize {
            imageView.snp.makeConstraints { (make) in
                make.width.equalTo(size.width)
                make.height.equalTo(size.height)
            }
        }
    }

    func buildLabel(style: Style) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        return titleLabel
    }

    func buildButton(_ title: String, style: Style) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(Theme.shared[.majorText], for: .normal)
        return button
    }

    func commonInitView() {
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 10
        self.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
}
