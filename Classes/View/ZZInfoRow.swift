//
//  WKZInfoRow.swift
//  collection
//
//  Created by william on 02/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class ZZInfoRow: UIView {
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
    var iconView: UIImageView?

    public static func menuRow(title: String) -> ZZInfoRow {
        let row = ZZInfoRow()
        row.titleLabel.zText(title).zFontSize(15)
        row.valueLabel.font = UIFont.systemFont(ofSize: 15)

        return row
    }

    static public func iconMenuRow(icon: UIImage, title: String) -> ZZInfoRow {
        let row = ZZInfoRow()

        row.showIcon(icon)
        row.titleLabel.zText(title).zColor(AppTheme.shared[.title]).zFontSize(15)
        row.valueLabel.textAlignment = .right

        return row
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required public init?(coder aDecoder: NSCoder) {
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

    func showIcon(_ icon: UIImage) {
        if self.iconView == nil {
            let iconView = UIImageView()
            self.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.height.equalTo(30)
                make.width.equalTo(30)
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(15)
            })

            self.titleLabel.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(53)
            }

            self.iconView = iconView
        }

        self.iconView!.image = icon
    }

    func commonInitView() {
        self.backgroundColor = UIColor.white

        self.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = AppTheme.shared[.title]
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }

        self.addSubview(self.valueLabel)
        self.valueLabel.font = UIFont.systemFont(ofSize: 14)
        self.valueLabel.textColor = AppTheme.shared[.text]
        self.valueLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(100)
            make.right.equalToSuperview().offset(-15)
        }

//        self.addSubview(self.indicatorView)
//        self.indicatorView.isHidden = true
//        self.indicatorView.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.width.equalTo(6.5)
//            make.height.equalTo(12.5)
//            make.right.equalToSuperview().offset(-15)
//        }

    }

}
