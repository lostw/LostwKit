//
//  ToastActivityView.swift
//  Alamofire
//
//  Created by William on 2019/7/23.
//

import UIKit

public protocol ToastActivityView: UIView {
    var activityColor: UIColor? {get set}
    func setTitle(_ title: String?)
    func startAnimating()
    func stopAnimating()

}

class DefaultActivityView: UIView, ToastActivityView {
    var activityView: UIActivityIndicatorView!
    var titleLabel: UILabel!
    var activityColor: UIColor? {
        get {
            return activityView.color
        }
        set {
            activityView.color = newValue
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
