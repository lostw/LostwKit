//
//  UIImageViewExt.swift
//  Alamofire
//
//  Created by William on 2019/3/29.
//

import Foundation
import SDWebImage

extension UIImageView {
    public func loadImage(_ link: String?, placeholderImage: UIImage?) {
        self.image = nil
        if let link = link, let url = try? link.asURL() {
//            self.af_setImage(withURL: url, placeholderImage: placeholderImage)
            self.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            self.image = placeholderImage
        }
    }
}
