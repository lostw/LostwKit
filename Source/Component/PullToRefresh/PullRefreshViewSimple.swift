//
//  PullRefreshViewSimple.swift
//  Alamofire
//
//  Created by William on 2019/12/11.
//

import UIKit

final class PullRefreshViewSimple: UIView, PullRefreshView {
    var state: PullRefreshState = .pulling(0) {
        didSet {
            switch state {
            case .pulling(let progress):
                var alpha = progress
                if alpha > 0.8 {
                    alpha = 0.8
                }
                self.arrow.alpha = alpha
                if case let PullRefreshState.triggered = oldValue {
                    arrowRotationBack()
                } else if case let PullRefreshState.refreshing = oldValue {
                    arrowRotationBack()
                }
            case .triggered:
                arrowRotation()
            case .refreshing:
                startAnimating()
            case .stop:
                stopAnimating()
            case .stopped:
                break
            case .finish:
                break
            }
        }
    }

    var options: PullToRefreshOption
    var arrow: PullToRefreshArrow!
    var indicator: UIActivityIndicatorView!

    init(frame: CGRect, options: PullToRefreshOption) {
        self.options = options
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.arrow.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.indicator.center = self.arrow.center
    }

    func startAnimating() {
        self.indicator.startAnimating()
        self.arrow.isHidden = true
    }

    fileprivate func stopAnimating() {
        self.indicator.stopAnimating()
        self.arrow.isHidden = false
        self.arrow.alpha = 0

        UIView.animate(withDuration: 0.2, animations: {
            self.arrow.alpha = 1
            self.arrowRotationBack()
        }, completion: nil)
    }

    fileprivate func arrowRotation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            // -0.0000001 for the rotation direction control
            self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 0.0000001)
        }, completion: nil)
    }

    fileprivate func arrowRotationBack() {
//        UIView.animate(withDuration: 0.2, animations: {
            self.arrow.transform = CGAffineTransform.identity
//        })
    }

    func commonInitView() {
        self.autoresizingMask = .flexibleWidth

        self.backgroundColor = self.options.backgroundColor

        self.arrow = PullToRefreshArrow(frame: CGRect(x: 0, y: 0, width: 20, height: 22))
        self.arrow.backgroundColor = UIColor.clear
        self.arrow.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]

        self.indicator = UIActivityIndicatorView(style: .gray)
        self.indicator.bounds = self.arrow.bounds
        self.indicator.autoresizingMask = self.arrow.autoresizingMask
        self.indicator.hidesWhenStopped = true
        self.indicator.color = options.indicatorColor
        self.addSubview(indicator)
        self.addSubview(arrow)
    }
}
