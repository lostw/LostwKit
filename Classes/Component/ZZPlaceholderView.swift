//
//  ZZPlaceholderView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

public class ZZPlaceholderView: UIView {
    public struct Style {
        public var imageSize: CGSize?
        public var titleMarginTop: CGFloat = 20
        public var titleColor: UIColor = UIColor(hex: 0x7b888e)
        public var titleFont: UIFont = UIFont.systemFont(ofSize: 16)
        
        public var buttonSize: CGSize?
        public var configButton: ((UIButton)->Void) = { button in
            button.titleLabel!.font = UIFont.systemFont(ofSize: 16)
            button.titleLabel!.textColor = UIColor(hex: 0x333333)
        }
        
        public init() {}
    }
    
    public struct DataSource {
        public var indicator = false
        public var images: [String]?
        public var title: String?
        public var actionTitle: String?
        public var action: ((UIButton)->Void)?
        
        public var style = Style()
        
        public init() {}
    }
    
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var actionButton: UIButton?
    
    let container = UIView()
   
    var action: ((UIButton)->Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func load(dataSource: DataSource) {
        container.removeSubviews()
        
        let style = dataSource.style
        
        var lastView: UIView!
        if let imageNames = dataSource.images, !imageNames.isEmpty {
            let imageView = UIImageView()
            if imageNames.count == 1 {
                imageView.image = UIImage(named: imageNames.first!)
            } else {
                let images = imageNames.map { (str) -> UIImage in
                    return UIImage(named: str)!
                }
                imageView.animationImages = images
                imageView.animationDuration = 0.4
                imageView.animationRepeatCount = Int.max
                imageView.startAnimating()
            }
            container.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(4)
                if let size = style.imageSize {
                    make.width.equalTo(size.width)
                    make.height.equalTo(size.height)
                }
            }
            
            self.imageView = imageView
            lastView = imageView
        } else if dataSource.indicator {
            let activity = UIActivityIndicatorView(style: .whiteLarge)
            activity.color = UIColor(hex: 0x7b888e)
            activity.startAnimating()
            container.addSubview(activity)
            activity.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(4)
            }
            
            lastView = activity
        }
        
        if let title = dataSource.title {
            let titleLabel = UILabel()
            titleLabel.font = style.titleFont
            titleLabel.textColor = style.titleColor
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            container.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                if lastView == nil {
                    make.top.equalToSuperview().offset(4)
                } else {
                    make.top.equalTo(lastView.snp.bottom).offset(style.titleMarginTop)
                }
                
            }
            
            self.titleLabel = titleLabel
            lastView = titleLabel
        }
        
        if let actionTitle = dataSource.actionTitle {
            let button = UIButton()
            style.configButton(button)
            button.setTitle(actionTitle, for: .normal)
            container.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                if let size = style.buttonSize {
                    make.width.equalTo(size.width)
                    make.height.equalTo(size.height)
                }
                if lastView == nil {
                    make.top.equalToSuperview().offset(4)
                } else {
                    make.top.equalTo(lastView.snp.bottom).offset(30)
                }
            }
            
            self.action = dataSource.action
            button.addTarget(self, action: #selector(doAction), for: .touchUpInside)
            
            self.actionButton = button
            lastView = button
        }
        
        lastView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    func load(customView: UIView) {
        container.removeSubviews()
        
        container.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func doAction(_ sender: UIButton) {
        self.action?(sender)
    }
    
    func commonInitView() {
        self.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}
