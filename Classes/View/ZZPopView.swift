//
//  WKZPopView.swift
//  Zhangzhi
//
//  Created by william on 10/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class ZZPopView: UIView {
    static var queue = [ZZPopView]()
    static func nextView() {
        guard !self.queue.isEmpty else {
            return
        }
        
        let view = self.queue.first!
        if view.moveToView == nil {
            self.queue.remove(at: 0)
            self.nextView()
            return
        }
        view.show()
    }
    
    public enum Position {
        case center, onethird, bottom, top, point(CGPoint)
    }
    
    public enum AnimationType {
        case none, fade, push, scale, custom
    }
    
    public enum AnimationPushType {
        case fromTop, fromBottom, fromLeft, fromRight
    }
    
    weak var moveToView: UIView?
    fileprivate var dismissCallback: (()->Void)?
    public lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    public var dismissOnBackground = false {
        didSet {
            if dismissOnBackground {
                coverView.onTouch({ [unowned self](tap) in
                    self.dismiss()
                })
            } else {
               coverView.onTouch(nil)
            }
        }
    }
    public var animationType:AnimationType = .fade
    public var animationPushType:AnimationPushType = .fromTop
    public var delayTransform: CGAffineTransform?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showInWindow() {
        self.show(inView: UIApplication.shared.keyWindow!)
    }
    
    public func show(inView superview: UIView, position: Position = .center, size: CGSize? = nil) {
        if let size = size {
            self.bounds = CGRect(origin: .zero, size: size)
        }
        
        var x: CGFloat = (superview.bounds.width - self.bounds.width) / 2
        var y: CGFloat = 0
        switch position {
        case .center:
            y = (superview.bounds.height - self.bounds.height) / 2
        case .onethird:
            y = (superview.bounds.height - self.bounds.height) / 3
        case .bottom:
            y = superview.bounds.height - self.bounds.height
        case .top:
            break
        case .point(let point):
            x = point.x
            y = point.y
        }
        
        var rect = self.bounds
        rect.origin = CGPoint(x: x, y: y)
        self.frame = rect
        self.moveToView = superview
        ZZPopView.queue.append(self)
        ZZPopView.nextView()
    }
    
    fileprivate func show() {
        guard let superview = self.moveToView else {
            return
        }
        
        self.coverView.frame = superview.bounds
        self.coverView.alpha = 0.6
        superview.addSubview(self.coverView)
        superview.addSubview(self)
        
        self.pop()
    }
    
    func pop() {
        guard self.superview != nil else {
            return
        }
        
        if let transform = self.delayTransform {
            self.layoutIfNeeded()
            self.transform = transform
            self.setNeedsLayout()
        }
        
        switch self.animationType {
        case .none:break;
        case .fade:
            self.fadeIn()
        case .scale:
            self.scaleIn()
        case .push:
            self.pushIn()
        case .custom:
            self.animateIn()
        }
       
    }
    
    @objc public func close() {
        self.dismiss()
    }
    
    public func dismiss(completion: (()->Void)? = nil) {
        self.dismissCallback = completion
        
        switch self.animationType {
        case .none:
            self.cleanup()
        case .fade:
            self.fadeOut()
        case .scale:
            self.scaleOut()
        case .push:
            self.pushOut()
        case .custom:
            self.animateOut()
        }
    }
    
    public func cleanup() {
        self.coverView.removeFromSuperview()
        self.removeFromSuperview()
        if let callback = self.dismissCallback {
            callback()
        }
        
        ZZPopView.queue.remove(at: 0)
        ZZPopView.nextView()
    }
    
    func animateIn() {}
    
    func animateOut() {}
    
    fileprivate func fadeIn() {
        self.alpha = 0
        self.coverView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.coverView.alpha = 0.6
        }
    }
    
    fileprivate func fadeOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0;
            self.coverView.alpha = 0;
        }) { (finished) in
            self.cleanup()
        }
    }
    
    fileprivate func scaleIn() {
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01);
        self.coverView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { 
            self.transform = CGAffineTransform.identity;
            self.coverView.alpha = 0.6;
        })
    }
    
    fileprivate func scaleOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01);
            self.coverView.alpha = 0;
        }) { (finished) in
            self.cleanup()
        }
    }
    
    fileprivate func pushIn() {
        var startRect = self.frame
        let endRect = self.frame
        
        switch self.animationPushType {
        case .fromTop:
            startRect.origin.y = -startRect.height
        case .fromBottom:
            startRect.origin.y = self.superview!.bounds.height + startRect.size.height
        case .fromLeft:
            startRect.origin.x = -startRect.width
        case .fromRight:
            startRect.origin.x = self.superview!.bounds.width + startRect.size.width
        }
        
        self.frame = startRect
        self.coverView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.frame = endRect
            self.coverView.alpha = 0.6;
        })
    }
    
    fileprivate func pushOut() {
        var endRect = self.frame
        
        switch self.animationPushType {
        case .fromTop:
            endRect.origin.y = -endRect.height
        case .fromBottom:
            endRect.origin.y = self.superview!.bounds.height + endRect.size.height
        case .fromLeft:
            endRect.origin.x = -endRect.width
        case .fromRight:
            endRect.origin.x = self.superview!.bounds.width + endRect.size.width
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = endRect
            self.coverView.alpha = 0;
        }) { (finished) in
            self.cleanup()
        }
    }
    
    open func commonInitView() {
        self.layer.cornerRadius = 5
        self.layer.backgroundColor = UIColor.white.cgColor
    }
}
