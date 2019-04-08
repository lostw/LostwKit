//
//  WKZInputRow.swift
//  Zhangzhi
//
//  Created by william on 04/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

@objcMembers
class ZZInputRow: UIView {
    let field: UITextField = ZZTextField()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPlaceholder(_ p: String?) {
        if let p = p {
            self.field.attributedPlaceholder = NSMutableAttributedString(string: p, attributes: [.foregroundColor: AppTheme.shared[.promptText]])
        } else {
            self.field.attributedPlaceholder = nil
        }
    }
    
    func disableFieldAction() {
        (self.field as! ZZTextField).disableAction = true
    }
    
    func commonInitView() {
        self.backgroundColor = UIColor.white
        
        self.titleLabel.zFontSize(14).zColor(AppTheme.shared[.title])
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        self.field.font = UIFont.systemFont(ofSize: 14)
        self.field.textColor = AppTheme.shared[.text]
        self.field.clearButtonMode = .whileEditing
        self.addSubview(self.field)
        self.field.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(0)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-15)
        }
    }

}
