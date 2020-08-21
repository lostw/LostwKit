//
//  UIImageViewExt.swift
//  Alamofire
//
//  Created by William on 2019/3/29.
//

import Foundation
import Kingfisher

extension UIImageView {
    public func loadImage(_ link: String?, placeholderImage: UIImage?) {
        self.image = nil
        if let link = link, let url = try? link.asURL() {
            self.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            self.image = placeholderImage
        }
    }
}
