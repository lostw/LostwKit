//
//  ZZToggleRow.swift
//  Alamofire
//
//  Created by William on 2019/5/20.
//

import UIKit
import SnapKit

public class ZZToggleRow: UIView {
    public var titleLabel: UILabel!
    public var switcher: UISwitch!
    public var onToggle: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func toggle(sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
    func commonInitView() {
        backgroundColor = .white
        
        titleLabel = UILabel()
        self.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textColor = AppTheme.shared[.title]
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }

        switcher = UISwitch()
        addSubview(switcher)
        switcher.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.centerY.equalToSuperview()
        }
        switcher.addTarget(self, action: #selector(toggle), for: .valueChanged)
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}
