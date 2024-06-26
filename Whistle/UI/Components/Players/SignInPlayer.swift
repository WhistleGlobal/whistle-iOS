//
//  SignInPlayer.swift
//  Whistle
//
//  Created by ChoiYujin on 9/21/23.
//

import AVFoundation
import Foundation
import SwiftUI

// MARK: - SignInPlayer

struct SignInPlayer: UIViewRepresentable {
  func updateUIView(_: UIView, context _: UIViewRepresentableContext<SignInPlayer>) { }

  func makeUIView(context _: Context) -> UIView {
    SignInPlayerLayer(frame: .zero)
  }
}

// MARK: - SignInPlayerLayer

class SignInPlayerLayer: UIView {
  private let playerLayer = AVPlayerLayer()

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(
      forResource: "whistleSignInBackground",
      ofType: "mp4")!))
    playerLayer.player = player
    playerLayer.videoGravity = .resizeAspectFill
    layer.addSublayer(playerLayer)

    player.actionAtItemEnd = .none
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerItemDidReachEnd(notification:)),
      name: .AVPlayerItemDidPlayToEndTime,
      object: player.currentItem)
    player.play()
  }

  @objc
  func playerItemDidReachEnd(notification _: Notification) {
    playerLayer.player?.seek(to: CMTime.zero)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = bounds
  }
}
