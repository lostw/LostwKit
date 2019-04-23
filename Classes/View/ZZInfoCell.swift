//
//  ZZInfoCell.swift
//  Zhangzhilicai
//
//  Created by william on 17/10/2017.
//Copyright © 2017 william. All rights reserved.
//

import UIKit
import SnapKit

public class ZZInfoCell: UIView {
    public var titleLabel: UILabel!
    public var valueLabel: UILabel!

    private var gapConstraint: Constraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func adjustGap(_ gap: CGFloat) {
        self.gapConstraint.update(offset: gap)
    }

    func commonInitView() {
        self.backgroundColor = UIColor.white

        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        self.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = AppTheme.shared[.title]
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(-4)
        }

        valueLabel = UILabel()
        valueLabel.textAlignment = .center
        self.addSubview(self.valueLabel)
        self.valueLabel.font = UIFont.systemFont(ofSize: 14)
        self.valueLabel.textColor = AppTheme.shared[.promptText]
        self.valueLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            self.gapConstraint = make.top.equalTo(self.titleLabel.snp.bottom).offset(8).constraint
        }
    }
}
