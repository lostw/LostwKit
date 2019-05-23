//
//  ZZImagePreviewView.swift
//  Alamofire
//
//  Created by William on 2019/5/22.
//

import UIKit

public class ZZImagePreviewView: UIView {
    public var image: UIImage! {
        didSet {
            setupImage(image)
        }
    }
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupImage(_ image: UIImage) {
        scrollView.zoomScale = 1
        imageView.image = image
        setNeedsLayout()
    }

    func reset() {
        scrollView.zoomScale = 1
    }
    
    func commonInitView() {
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        scrollView.scrollsToTop = false

        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)

        scrollView.addSubview(imageView)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let frame: CGRect = [10, 0, self.bounds.width - 20, self.bounds.height]
        scrollView.frame = frame

        if let image = imageView.image {
            let imageSize = image.size
            let wRatio = image.size.width / scrollView.bounds.width
            let hRatio = image.size.height / scrollView.bounds.height

            var width: CGFloat = 0
            var height: CGFloat = 0
            if wRatio > hRatio {
                width = scrollView.bounds.width
                height = image.size.height / image.size.width * width
            } else {
                height = scrollView.bounds.height
                width = image.size.width / image.size.height * height
            }
            
            scrollView.zoomScale = 1
            imageView.frame = scrollView.bounds.rectForCenterSize(CGSize(width, height))
            scrollView.contentSize = scrollView.bounds.size
        }
    }
}

extension ZZImagePreviewView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustImageViewCenter()
    }

    func adjustImageViewCenter() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        let centerPoint: CGPoint = [scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY]
        imageView.center = centerPoint
    }
}
