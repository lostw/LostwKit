//
//  WKZInputRow.swift
//  Zhangzhi
//
//  Created by william on 04/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public class ZZInputRow: UIView {
    public let field: UITextField = ZZTextField()
    public let titleLabel = UILabel()
    public var onBlur: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setPlaceholder(_ p: String?) {
        if let p = p {
            self.field.attributedPlaceholder = NSMutableAttributedString(string: p, attributes: [.foregroundColor: Theme.shared[.promptText]])
        } else {
            self.field.attributedPlaceholder = nil
        }
    }

    public func disableFieldAction() {
        (self.field as! ZZTextField).disableAction = true
    }

    func commonInitView() {
        backgroundColor = .white

        titleLabel.zFontSize(14).zColor(Theme.shared[.title])
        addSubview(self.titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        field.font = UIFont.systemFont(ofSize: 14)
        field.textColor = Theme.shared[.text]
        field.clearButtonMode = .whileEditing
        field.delegate = self
        addSubview(self.field)
        field.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(0)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-15)
        }
    }
}

extension ZZInputRow: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        onBlur?()
    }
}
