//
//  ToastActivityView.swift
//  Alamofire
//
//  Created by William on 2019/7/23.
//

import UIKit

class DefaultIndicatorView: UIView, IndicatorView {
    var activityView: UIActivityIndicatorView!
    let titleLabel = UILabel()
    var text: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }

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

        titleLabel.zFontSize(14).zColor(.white)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }
    }
}
