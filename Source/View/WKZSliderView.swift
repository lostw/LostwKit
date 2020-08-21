//
//  WKZSliderView.swift
//  Zhangzhi
//
//  Created by william on 29/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit
//import AlamofireImage

public typealias TouchAction = (_ idx: Int) -> Void

public class WKZSliderViewCell: UIView {
    var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func loadImage(_ link: String?, placeholderImage: UIImage?) {
        self.imageView.loadImage(link, placeholderImage: placeholderImage)
    }
}

public class WKZSliderView: UIView {
    public let pageControl = UIPageControl()
    public let scrollView = UIScrollView()
    public var placeholderView: UIImageView?
    public var configImageViewAction: ((UIImageView) -> Void)?
    var timer: Timer?
    public var autoScroll = false {
        didSet {
            guard self.links != nil else {
                self.cancelTimer()
                return
            }

            if self.autoScroll && self.links!.count > 1 {
                self.setupTimer()
            } else {
                self.cancelTimer()
                //处理未滑动完成的情况
                if self.scrollView.contentOffset.x > self.bounds.width {
                    self.scrollToNextPage(animated: false)
                    self.updateView()
                }

            }
        }
    }
    public var autoInterval = 3.0

    var placeholderImage: UIImage?
    public var touchAction: TouchAction?
    var links: [String]?
    var currentPage = 0 {
        didSet {
            self.pageControl.currentPage = self.currentPage
        }
    }

    private var firstView: WKZSliderViewCell?
    private var middleView: WKZSliderViewCell?
    private var lastView: WKZSliderViewCell?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        self.scrollView.frame = self.bounds
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.isPagingEnabled = true
        self.addSubview(self.scrollView)

        self.pageControl.frame = CGRect(x: 0, y: self.bounds.height - 20, width: self.bounds.width, height: 20)
        self.pageControl.hidesForSinglePage = true
        self.addSubview(self.pageControl)

        self.onTouch { [weak self] tap in
            guard let self = self, let links = self.links else { return }

            let location = tap.location(in: self.scrollView)
            var i = self.currentPage
            if links.count == 1 {
                i = 0
            } else {
                if location.x > self.scrollView.bounds.width * 2 {
                    i += 1
                } else if location.x < self.scrollView.bounds.width {
                    i -= 1
                }
            }

            if i > links.count - 1 {
                i = 0
            } else if i < 0 {
                i = links.count - 1
            }

            if let callback = self.touchAction {
                callback(i)
            }
        }
    }

    public func loadImages(byLink links: [String]) {
        guard !links.isEmpty else {
            return
        }
        if !self.isDifferentLinks(links) {
            return
        }

        self.links = links

        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }

        let width = self.bounds.width
        let height = self.bounds.height
        if self.links!.count == 1 {
            if self.firstView == nil {
                self.firstView = self.buildImageView()
            } else {
                self.firstView!.frame = self.bounds
            }

            self.scrollView.addSubview(self.firstView!)
            self.firstView?.loadImage(self.links?.first, placeholderImage: self.placeholderImage)
            self.scrollView.contentOffset = CGPoint.zero
            self.scrollView.contentSize = self.bounds.size
        } else {

            if self.firstView == nil {
                self.firstView = self.buildImageView()
            }
            self.firstView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
            self.firstView!.loadImage(self.links?.last, placeholderImage: self.placeholderImage)
            self.scrollView.addSubview(self.firstView!)

            if self.middleView == nil {
                self.middleView = self.buildImageView()
            }
            self.middleView!.frame = CGRect(x: width, y: 0, width: width, height: height)
            self.middleView!.loadImage(self.links?.first, placeholderImage: self.placeholderImage)
            self.scrollView.addSubview(self.middleView!)

            if self.lastView == nil {
                self.lastView = self.buildImageView()
            }
            self.lastView!.frame = CGRect(x: width * 2, y: 0, width: width, height: height)
            self.lastView!.loadImage(self.links![1], placeholderImage: self.placeholderImage)
            self.scrollView.addSubview(self.lastView!)

            self.scrollView.contentOffset = CGPoint(x: width, y: 0)
            self.scrollView.contentSize = CGSize(width: 3 * width, height: height)
        }

        self.pageControl.numberOfPages = self.links!.count
        let size = self.pageControl.size(forNumberOfPages: self.links!.count)
        self.pageControl.frame = CGRect(x: (width - size.width - 10) / 2, y: height - 50, width: size.width + 10, height: 20)

        self.cancelTimer()
        if self.autoScroll && self.links!.count > 1 {
            self.setupTimer()
        }
    }

    func updateView() {
        guard let links = self.links, links.count > 1 else {
            return
        }

        let offsetPage = Int(self.scrollView.contentOffset.x / self.scrollView.bounds.width)

        let width = self.bounds.width
        let height = self.bounds.height

        if offsetPage == 0 {
            self.currentPage -= 1
            if self.currentPage < 0 {
                self.currentPage = links.count - 1
            }

            let tmp = self.lastView!

            self.lastView = self.middleView
            self.lastView!.frame = CGRect(x: width * 2, y: 0, width: width, height: height)

            self.middleView = self.firstView
            self.middleView!.frame = CGRect(x: width, y: 0, width: width, height: height)

            self.firstView = tmp
            self.firstView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
            var prevPage = self.currentPage - 1
            if prevPage < 0 {
                prevPage = self.links!.count - 1
            }
            self.firstView!.loadImage(self.links![prevPage], placeholderImage: self.placeholderImage)
            self.scrollView.contentOffset = CGPoint(x: width, y: 0)
        }

        if offsetPage == 2 {
            self.currentPage += 1
            if self.currentPage > links.count - 1 {
                self.currentPage = 0
            }

            let tmp = self.firstView!

            self.firstView = self.middleView
            self.firstView!.frame = CGRect(x: 0, y: 0, width: width, height: height)

            self.middleView = self.lastView
            self.middleView!.frame = CGRect(x: width, y: 0, width: width, height: height)

            self.lastView = tmp
            self.lastView!.frame = CGRect(x: width * 2, y: 0, width: width, height: height)
            var prevPage = self.currentPage + 1
            if prevPage > self.links!.count - 1 {
                prevPage = 0
            }
            self.lastView!.loadImage(links[prevPage], placeholderImage: self.placeholderImage)
            self.scrollView.contentOffset = CGPoint(x: width, y: 0)
        }
    }

    func nextPage() {
        guard !self.scrollView.isTracking else {
            return
        }

        self.scrollToNextPage(animated: true)
    }

    func scrollToNextPage(animated: Bool) {
        let rect = CGRect(x: 2 * self.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.scrollView.scrollRectToVisible(rect, animated: animated)
    }

    // MARK: - timer
    private func setupTimer() {
        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(withTimeInterval: self.autoInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.nextPage()
        }
    }

    private func cancelTimer() {
        self.timer?.invalidate()
    }

    private func buildImageView() -> WKZSliderViewCell {
        let view = WKZSliderViewCell(frame: self.bounds)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false

        self.configImageViewAction?(view.imageView)

        return view
    }

    private func isDifferentLinks(_ links: [String]) -> Bool {
        if let currentLinks = self.links, currentLinks.count == links.count {
            for (idx, item) in links.enumerated() where item != currentLinks[idx] {
                return true
            }

            return false
        }

        return true
    }
}

extension WKZSliderView: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.updateView()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateView()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updateView()
    }
}
