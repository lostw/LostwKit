//
//  ZZPlaceholderView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

public class ZZPlaceholderView: UIView {
    public struct Style {
        public var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        public var imageSize: CGSize?
        public var titleMarginTop: CGFloat = 20
        public var titleColor: UIColor = UIColor(hex: 0x7b888e)
        public var titleFont: UIFont = UIFont.systemFont(ofSize: 16)

        public var buttonSize: CGSize?
        public var configButton: ((UIButton) -> Void) = { button in
            button.titleLabel!.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(AppTheme.shared[.majorText], for: .normal)
        }

        public init() {}
    }

    public struct DataSource {
        public var indicator = false
        public var images: [String]?
        public var title: String?
        public var attributedTitle: NSAttributedString?
        public var actionTitle: String?
        public var action: ((UIButton) -> Void)?
        public var pageAction: VoidClosure?
        public var style = Style()

        public init() {}
    }

    var imageView: UIImageView?
    var titleLabel: UILabel?
    var actionButton: UIButton?

    let container = WKZLinearView()

    var action: ((UIButton) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func load(dataSource: DataSource) {
        container.removeAllLinearViews()
        container.padding = dataSource.style.padding

        self.addImageView(dataSource)
        self.addTitleLabel(dataSource)
        self.addActionButton(dataSource)

        if let action = dataSource.pageAction {
            self.onTouch { _ in
                action()
            }
        } else {
            self.onTouch(nil)
        }
    }

    func load(customView: UIView) {
        container.removeSubviews()

        container.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func doAction(_ sender: UIButton) {
        self.action?(sender)
    }

    func addImageView(_ dataSource: DataSource) {
        if let imageNames = dataSource.images, !imageNames.isEmpty {
            let imageView = UIImageView()
            if imageNames.count == 1 {
                imageView.image = UIImage(named: imageNames.first!)
            } else {
                let images = imageNames.map { (str) -> UIImage in
                    return UIImage(named: str)!
                }
                imageView.animationImages = images
                imageView.animationDuration = 0.4
                imageView.animationRepeatCount = Int.max
                imageView.startAnimating()
            }
            imageView.zLinearLayout.justifyContent = .center
            container.addLinearView(imageView)
            if let size = dataSource.style.imageSize {
                imageView.snp.makeConstraints { (make) in
                    make.width.equalTo(size.width)
                    make.height.equalTo(size.height)
                }
            }

            self.imageView = imageView
        } else if dataSource.indicator {
            let activity = UIActivityIndicatorView(style: .whiteLarge)
            activity.color = UIColor(hex: 0x7b888e)
            activity.startAnimating()
            activity.zLinearLayout.justifyContent = .center
            container.addLinearView(activity)
        }
    }

    func addTitleLabel(_ dataSource: DataSource) {
        let style = dataSource.style
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

    func addActionButton(_ dataSource: DataSource) {
        let style = dataSource.style
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
