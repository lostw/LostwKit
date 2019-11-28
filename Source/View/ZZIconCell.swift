//
//  ZZIconCell.swift
//  Alamofire
//
//  Created by William on 2019/3/27.
//

import UIKit
import SnapKit

public class ZZIconCell: UIView {
    public var titleLabel: UILabel!
    public var iconView: UIImageView!

    private var gapConstraint: Constraint!
    private var iconOffsetYConstraint: Constraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func adjustGap(_ gap: CGFloat) {
        self.gapConstraint.update(offset: gap)
    }

    public func adjustIconOffsetY(_ y: CGFloat) {
        iconOffsetYConstraint.update(inset: y)
    }

    func commonInitView() {
        self.backgroundColor = UIColor.white

        iconView = UIImageView()
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            self.iconOffsetYConstraint =  make.centerY.equalToSuperview().offset(-10).constraint

        }

        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        self.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = Theme.shared[.title]
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
//            make.bottom.equalTo(self.snp.centerY).offset(-4)
            self.gapConstraint = make.top.equalTo(self.iconView.snp.bottom).offset(8).constraint
        }
    }
}
