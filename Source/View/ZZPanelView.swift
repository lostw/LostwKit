//
//  ZZPanelView.swift
//  Alamofire
//
//  Created by William on 2019/3/27.
//

import UIKit

public class ZZPanelView: UIView {
    public var titleLabel: UILabel!
    var contentWrapperView: UIView!
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addContentView(_ view: UIView) {
        contentWrapperView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func commonInitView() {
        self.backgroundColor = .white

        titleLabel = UILabel()
        titleLabel.zFontSize(17).zColor(UIColor(hex: 0x1a1a1a))
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(15)
        }

        contentWrapperView = UIView()
        self.addSubview(contentWrapperView)
        contentWrapperView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(10).priority(.low)
        }
    }
}
