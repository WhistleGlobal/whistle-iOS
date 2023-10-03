//
//  PlayerView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

struct EditablePlayerView: UIViewControllerRepresentable {
  var player: AVPlayer
  let scale = 16 / 9
  typealias UIViewControllerType = AVPlayerViewController

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    let view = AVPlayerViewController()
    view.player = player
    view.showsPlaybackControls = false
    view.videoGravity = .resizeAspect
    view.contentOverlayView?.layer.cornerRadius = 12
    view.contentOverlayView?.layer.masksToBounds = true
//    view.contentOverlayView?.snp.makeConstraints { make in
//      make.top.equalToSuperview().offset(50)
//      make.bottom.equalToSuperview()
//      make.left.equalToSuperview()
//      make.right.equalToSuperview()
//    }
//
//    view.contentOverlayView?.layer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 203, height: 361))
//    view.contentOverlayView?.layer.borderColor = UIColor.red.cgColor
//    view.contentOverlayView?.layer.borderWidth = 10
    return view
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context _: Context) {
    uiViewController.player = player
  }
}
