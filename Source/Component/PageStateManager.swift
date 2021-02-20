//
//  AppointmentFamilyListController.swift
//  HealthTaiZhou
//
//  Created by William on 2018/12/20.
//  Copyright © 2018 Wonders. All rights reserved.
//

import UIKit
import LostwKit

public protocol StateView: UIView {
    func asLoading(percent: CGFloat)
    func asError(_ errorText: String?)
    func asEmpty()
}

public class DefaultStateView: UIView, StateView {
    public func asEmpty() {
        self.titleLabel.text = config.emptyText
        self.imageView.image = config.emptyImage.image

        indicatorView.isHidden = true
        imageView.isHidden = false
        imageView.animationImages = nil
    }

    public func asLoading(percent: CGFloat) {
        self.titleLabel.text = config.loadingText
        switch config.loadingStyle {
        case .indicator:
            indicatorView.isHidden = false
            indicatorView.startAnimating()
            imageView.isHidden = true
        case .single(let resource):
            indicatorView.isHidden = true
            indicatorView.stopAnimating()
            imageView.isHidden = false
            imageView.image = resource.image
        case .muliple(let resources, let duration):
            indicatorView.isHidden = true
            indicatorView.stopAnimating()
            imageView.isHidden = false
            imageView.animationImages = resources.flatMap { $0.image }
            imageView.animationDuration = duration
            imageView.startAnimating()
        }
    }

    public func asError(_ errorText: String? = nil) {
        self.titleLabel.text = errorText ?? config.errorText
        self.imageView.image = config.errorImage.image
        indicatorView.isHidden = true
        imageView.isHidden = false
        imageView.animationImages = nil
    }

    let indicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.color = UIColor(hex: 0x7b888e)
        return activity
    }()
    let imageView = UIImageView()
    var titleLabel = UILabel()

    let container = UIStackView()
    var config: PageStateManager.DefaultConfiguration

    public init(config: PageStateManager.DefaultConfiguration) {
        self.config = config
        super.init(frame: .zero)
        self.commonInitView()
    }

    override init(frame: CGRect) {
        fatalError("use init(config:)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        container.axis = .vertical
        container.alignment = .center
        container.spacing = config.spacing
        self.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(config.yOffset)
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        container.addArrangedSubview(indicatorView)
        container.addArrangedSubview(imageView)

        titleLabel.textColor = Theme.shared.text
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        container.addArrangedSubview(titleLabel)
    }
}

public enum LoadingStyle {
    case indicator
    case single(ImageResource)
    case muliple([ImageResource], TimeInterval)
}

public final class PageStateManager {
    public static var globalConfig = DefaultConfiguration()
    public enum State {
        case hidden
        case loading(_ percent: CGFloat)
        case empty
        case error(_ errorText: String?)
    }

    public struct DefaultConfiguration {
        public var spacing: CGFloat = 15
        public var yOffset: CGFloat = -20

        public var loadingText: String = "加载中..."
        public var loadingStyle: LoadingStyle = .indicator
        public var emptyText: String = "暂无数据"
        public var emptyImage: ImageResource = .buildin("icon_record_none")
        public var errorText: String = "未知错误"
        public var errorImage: ImageResource = .buildin("icon_record_fail")
    }

    public enum Configuration {
        case `default`(DefaultConfiguration)
        case custom(StateView)
    }

    var stateView: StateView
    public var state: State = .loading(0) {
        didSet {
            switch state {
            case .hidden:
                self.stateView.isHidden = true
            case .loading(let percent):
                self.stateView.isHidden = false
                self.stateView.asLoading(percent: percent)
            case .empty:
                self.stateView.isHidden = false
                self.stateView.asEmpty()
            case .error(let errorText):
                self.stateView.isHidden = false
                self.stateView.asError(errorText)
            }
        }
    }

    public var masterView: UIView! {
        didSet {
            if masterView != nil {
                if masterView.isKind(of: UITableView.self) || masterView.isKind(of: UICollectionView.self) || masterView.isKind(of: UIScrollView.self) {
                    masterView.insertSubview(self.stateView, at: 0)
                } else {
                    masterView.addSubview(self.stateView)
                    self.stateView.snp.makeConstraints { (make) in
                        make.edges.equalToSuperview()
                    }
                }
            }
        }
    }

    public init(config: Configuration) {
        switch config {
        case .default(let viewConfig):
            let view = DefaultStateView(config: viewConfig)
            self.stateView = view
        case .custom(let view):
            self.stateView = view
        }
    }
}
