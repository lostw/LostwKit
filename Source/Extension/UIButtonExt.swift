//
//  UIButtonExt.swift
//  Alamofire
//
//  Created by Mac on 2019/4/16.
//

import Foundation

public extension UIButton {

    /**
     UIButton图像文字同时存在时---图像相对于文字的位置

     - top:    图像在上
     - left:   图像在左
     - right:  图像在右
     - bottom: 图像在下
     */
    public enum ImageLayoutStyle {
        case top, left, right, bottom
    }

    func imagePosition(at style: ImageLayoutStyle, space: CGFloat) {
        self.layoutIfNeeded()
        guard let imageV = imageView else { return }
        guard let titleL = titleLabel else { return }
        //获取图像的宽和高
        let imageWidth = imageV.frame.size.width
        let imageHeight = imageV.frame.size.height
        //获取文字的宽和高
        let labelWidth  = titleL.intrinsicContentSize.width
        let labelHeight = titleL.intrinsicContentSize.height

        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        //UIButton同时有图像和文字的正常状态---左图像右文字，间距为0
        switch style {
        case .left:
            //正常状态--只不过加了个间距
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -space * 0.5, bottom: 0, right: space * 0.5)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: space * 0.5, bottom: 0, right: -space * 0.5)
        case .right:
            //切换位置--左文字右图像
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth + space * 0.5, bottom: 0, right: -labelWidth - space * 0.5)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth - space * 0.5, bottom: 0, right: imageWidth + space * 0.5)
        case .top:
            //切换位置--上图像下文字
            imageEdgeInsets = UIEdgeInsets(top: -(labelHeight + space) * 0.5, left: labelWidth * 0.5, bottom: (labelHeight + space) * 0.5, right: -labelWidth * 0.5)
            labelEdgeInsets = UIEdgeInsets(top: (imageHeight + space) * 0.5, left: -imageWidth * 0.5, bottom: -(imageHeight + space) * 0.5, right: imageWidth * 0.5)
        case .bottom:
            //切换位置--下图像上文字
            imageEdgeInsets = UIEdgeInsets(top: (labelHeight + space) * 0.5, left: labelWidth * 0.5, bottom: -(labelHeight + space) * 0.5, right: -labelWidth * 0.5)
            labelEdgeInsets = UIEdgeInsets(top: -(imageHeight + space) * 0.5, left: -imageWidth * 0.5, bottom: (imageHeight + space) * 0.5, right: imageWidth * 0.5)
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}
