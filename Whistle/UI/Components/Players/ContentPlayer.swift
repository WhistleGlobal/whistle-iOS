//
//  ContentPlayer.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI

// MARK: - ContentPlayer

struct ContentPlayer: UIViewControllerRepresentable {
  var player: AVPlayer

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    let view = AVPlayerViewController()
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playback)
      try audioSession.setActive(true)
    } catch {
      WhistleLogger.logger.error("\(error)")
    }
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
