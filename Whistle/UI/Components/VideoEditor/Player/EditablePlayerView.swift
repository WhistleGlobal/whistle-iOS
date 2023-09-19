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

  typealias UIViewControllerType = AVPlayerViewController

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    let view = AVPlayerViewController()
    view.player = player
    view.showsPlaybackControls = false
    view.videoGravity = .resizeAspectFill
    return view
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context _: Context) {
    uiViewController.player = player
  }
}
