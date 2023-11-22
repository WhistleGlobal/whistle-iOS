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
  var aspectRatio: Double?

  func makeUIViewController(context _: Context) -> AVPlayerViewController {
    WhistleLogger.logger.debug("ContentPlayer: \(player.debugDescription)")
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
    if aspectRatio ?? 1.0 > Double(15.0 / 9.0) {
      view.videoGravity = .resizeAspectFill
    } else {
      view.videoGravity = .resizeAspect
    }
    view.view.isUserInteractionEnabled = false
    view.view.backgroundColor = .clear

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
