//
//  EditablePlayerView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

struct EditablePlayer: UIViewControllerRepresentable {
  var player: AVPlayer
  var isFullScreen = false
  typealias UIViewControllerType = AVPlayerViewController

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    let view = AVPlayerViewController()
    view.player = player
    view.showsPlaybackControls = false
    if isFullScreen {
      view.videoGravity = .resizeAspectFill
    } else {
      view.videoGravity = .resizeAspect
    }
    view.contentOverlayView?.layer.cornerRadius = 12
    view.contentOverlayView?.layer.masksToBounds = true
    view.allowsVideoFrameAnalysis = false
    return view
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context _: Context) {
    uiViewController.player = player
  }
}
