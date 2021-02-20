//
//  InfoRow.swift
//  Alamofire
//
//  Created by William on 2020/8/25.
//

import UIKit

public enum ImageResource {
    case buildin(String)    // lostwKit内置图片
    case mainBundle(String) // 主项目图片
    case link(String, _ placeholder: UIImage?) // 网络图片

    /// 注意：对于网络图片，只会返回占位图
    public var image: UIImage? {
        switch self {
        case .buildin(let name):
            return UIImage.bundleImage(named: name)
        case .mainBundle(let name):
            return UIImage(named: name)
        case .link(_, let placeholder):
            return placeholder
        }
    }
}

public class InfoRow: UIView {
    public enum InfoRowStyle {
        case horizontal
        case vertical
        case iconMenu(ImageResource)
        case flexableIconMenu(ImageResource, CGSize)
    }
    public static func row(style: InfoRowStyle = .horizontal) -> InfoRow {
        switch style {
        case .horizontal:
            return HorizontalInfoRow()
        case .vertical:
            return VerticalInfoRow()
        case .iconMenu(let resource):
            return IconMenuInfoRow(resource: resource, size: CGSize(width: 30, height: 30))
        case .flexableIconMenu(let resource, let size):
            return IconMenuInfoRow(resource: resource, size: size)
        }

    }

    public let titleLabel = UILabel()
    public let valueLabel = UILabel()
    lazy var indicatorView: UIImageView = {
        let view = UIImageView(image: UIImage.bundleImage(named: "icon_indicator"))
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(6.5)
            make.height.equalTo(12.5)
            make.right.equalToSuperview().offset(-15)
        })
        return view
    }()

    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc public override func onTouch(_ action: UIViewTapAction?) {
        super.onTouch(action)

        self.toggleIndicatorView((action == nil ? false : true))
    }

    public func toggleIndicatorView(_ show: Bool, adjust: Bool = true) {
        self.indicatorView.isHidden = !show
        if adjust {
            self.valueLabel.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(show ? -27 : -15)
            })
        }
    }

    func commonInitView() {
        self.backgroundColor = UIColor.white

        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = Theme.shared[.title]
        self.addSubview(self.titleLabel)

        self.addSubview(self.valueLabel)
        self.valueLabel.font = UIFont.systemFont(ofSize: 14)
        self.valueLabel.textColor = Theme.shared[.text]
    }
}

class HorizontalInfoRow: InfoRow {
    override func commonInitView() {
        super.commonInitView()
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
        }

        self.valueLabel.snp.makeConstraints {
           $0.centerY.equalToSuperview()
           $0.left.equalToSuperview().offset(100)
           $0.right.equalToSuperview().offset(-15)
       }
    }
}

class VerticalInfoRow: InfoRow {
    override func commonInitView() {
        super.commonInitView()

        self.valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(6)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        titleLabel.textColor = Theme.shared.text
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        self.titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.valueLabel.snp.top).offset(-2)
            $0.left.equalToSuperview().offset(15)
        }
    }
}

class IconMenuInfoRow: InfoRow {
    let iconView = UIImageView()

    init(resource: ImageResource, size: CGSize) {
        super.init(frame: .zero)

        iconView.snp.makeConstraints {
            $0.height.equalTo(size.height)
            $0.width.equalTo(size.width)
        }

        switch resource {
        case .mainBundle(let name):
            iconView.image = UIImage(named: name)
        case .link(let link, let placeholder):
            iconView.loadImage(link, placeholderImage: placeholder)
        case .buildin(let name):
            iconView.image = UIImage.bundleImage(named: name)
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func commonInitView() {
        super.commonInitView()

        self.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.width.equalTo(30)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
        }

        self.titleLabel.snp.makeConstraints {
             $0.centerY.equalToSuperview()
            $0.left.equalTo(iconView.snp.right).offset(8)
         }

         self.valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(100)
            $0.right.equalToSuperview().offset(-15)
        }
    }
}
