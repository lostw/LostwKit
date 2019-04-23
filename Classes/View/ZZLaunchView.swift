//
//  ZZLaunchView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/8/6.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

public typealias ZZLaunchViewCallback = () -> Void
public class ZZLaunchView: UIView {
    private var imageView: UIImageView!
    private var skipLabel: UILabel?
    private var animationProgress: CAShapeLayer?

    var image: UIImage!
    var countSeconds: Int = 3
    var showSkip = false {
        didSet {
            if showSkip {
                self.showSkipButton()
            } else {
                self.skipLabel?.isHidden = true
            }
        }
    }
    var onTouch: ZZLaunchViewCallback?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.showSkip {
            self.showCountDownAnimation()
        } else {
            Timer.scheduledTimer(timeInterval: TimeInterval(self.countSeconds), target: self, selector: #selector(skip), userInfo: nil, repeats: false)
        }
    }

    public func showInView(_ view: UIView, image: UIImage, countSeconds: Int = 3, enableSkip: Bool = true, onTouch: ZZLaunchViewCallback? = nil) {
        self.frame = view.bounds
        self.imageView.image = image
        self.countSeconds = countSeconds
        self.showSkip = enableSkip
        self.onTouch = onTouch
        if onTouch != nil {
            imageView.onTouch { [unowned self] _ in
                self.hide(self.onTouch)
            }
        }
        view.addSubview(self)
    }

    @objc func skip() {
        self.hide()
    }

    func hide(_ callback: ZZLaunchViewCallback? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion:  { (_) in
            self.removeSubviews()
            callback?()
        })
    }

    func showCountDownAnimation() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(self.countSeconds)
        animation.delegate = self
        animationProgress?.add(animation, forKey: "progress")

    }

    // MARK: - initView
    func commonInitView() {
        imageView = UIImageView()
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

    }

    func showSkipButton() {
        if skipLabel == nil {
            let view = UIView()
            self.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(35)
                make.right.equalToSuperview().offset(-15)
                make.width.height.equalTo(40)
            }

            let label = UILabel()
            label.zText("跳过").zFontSize(14).zColor(AppTheme.shared[.majorText]).zAlign(.center).zBgColor(.clear)
            label.layer.cornerRadius = 20
            label.layer.borderColor = AppTheme.shared[.border].cgColor
            label.layer.borderWidth = 3
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            label.onTouch { [unowned self] (_) in
                self.skip()
            }
            skipLabel = label

            let animationLayer = CAShapeLayer()
            animationLayer.strokeColor = AppTheme.shared[.majorText].cgColor
            animationLayer.fillColor = UIColor.clear.cgColor
            animationLayer.frame = CGRect(0, 0, 40, 40)
            animationLayer.path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 18.5, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: true).cgPath
            animationLayer.strokeStart = 0
            animationLayer.strokeEnd = 0
            animationLayer.lineWidth = 3
            animationLayer.zPosition = 1000
            view.layer.addSublayer(animationLayer)
            animationProgress = animationLayer
        }

        skipLabel!.isHidden = false
    }

    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}

extension ZZLaunchView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animationProgress?.removeAnimation(forKey: "progress")
        self.hide()
    }
}
