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
    view.allowsVideoFrameAnalysis = false
    return view
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context _: Context) {
    uiViewController.player = player
  }
}
