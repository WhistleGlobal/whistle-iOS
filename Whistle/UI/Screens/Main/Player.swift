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
    view.showsPlaybackControls = false
    view.videoGravity = .resizeAspect
    return view
  }

  func updateUIViewController(_: AVPlayerViewController, context _: Context) { }
}
