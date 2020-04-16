//
//  ZZNavController.swift
//  Alamofire
//
//  Created by William on 2020/4/16.
//

import UIKit

open class ZZNavController: UINavigationController {

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension ZZNavController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
           if self.viewControllers.count < (navigationBar.items?.count ?? 0) {
               return true
           }

           var shouldPop = true
           if let vc = self.topViewController as? UINavigationBack {
               shouldPop = vc.shouldGoBack()
           }

           if shouldPop {
               DispatchQueue.main.async {
                   self.popViewController(animated: true)
               }
           }

           return false
       }
}
