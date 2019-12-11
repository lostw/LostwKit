//
//  ToastActivityView.swift
//  Alamofire
//
//  Created by William on 2019/7/23.
//

import UIKit

class DefaultActivityView: UIView, IndicatorView {
    var activityView: UIActivityIndicatorView!
    var titleLabel: UILabel!
    override var tintColor: UIColor! {
        didSet {
            activityView.color = tintColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String?) {
        self.titleLabel.text = title
    }

    func startAnimating() {
        self.activityView.startAnimating()
    }

    func stopAnimating() {
        self.activityView.stopAnimating()
    }

    func commonInitView() {
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(activityView)
        activityView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }

        titleLabel = UILabel()
        titleLabel.zFontSize(14).zColor(.white)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }
    }
}
