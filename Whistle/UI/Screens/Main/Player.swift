//
//  Player.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI

// MARK: - Player

struct Player: UIViewControllerRepresentable {

  var player: AVPlayer

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    let view = AVPlayerViewController()
    view.player = player
    if #available(iOS 16.0, *) {
      view.allowsVideoFrameAnalysis = false
    }
    view.showsPlaybackControls = false
    view.videoGravity = .resizeAspect
    NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: player.currentItem,
      queue: .main)
    { _ in
      player.seek(to: .zero)
      player.play()
    }
    return view
  }

  func updateUIViewController(_: AVPlayerViewController, context _: Context) { }
}
