//
//  UIViewViewController+video.swift
//  Alamofire
//
//  Created by William on 2019/10/25.
//

import UIKit
import AVKit

public extension UIViewController {
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
