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
    }

    public func asLoading(percent: CGFloat) {
        self.titleLabel.text = config.loadingText
        self.imageView.image = config.loadingImage.image
    }

    public func asError(_ errorText: String? = nil) {
        self.titleLabel.text = errorText ?? config.errorText
        self.imageView.image = config.errorImage.image
    }

    let imageView = UIImageView()
    var titleLabel = UILabel()

    let contentView = UIStackView()
    var config: PageStateManager.DefaultConfiguration!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        contentView.addArrangedSubview(imageView)

        titleLabel.textColor = Theme.shared.text
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addArrangedSubview(titleLabel)
    }
}

public final class PageStateManager {
    public enum State {
        case hidden
        case loading(_ percent: CGFloat)
        case empty
        case error(_ errorText: String?)
    }

    public struct DefaultConfiguration {
        var loadingText: String = "加载中..."
        var loadingImage: ImageResource = .buildin("icon_record_fail")
        var emptyText: String = "暂无数据"
        var emptyImage: ImageResource = .buildin("icon_record_none")
        var errorText: String = "未知错误"
        var errorImage: ImageResource = .buildin("icon_record_fail")
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

    public init(config: Configuration) {
        switch config {
        case .default(let viewConfig):
            let view = DefaultStateView()
            view.config = viewConfig
            self.stateView = view
        case .custom(let view):
            self.stateView = view
        }
    }

    
}
