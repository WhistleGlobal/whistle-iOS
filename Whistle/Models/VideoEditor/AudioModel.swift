//
//  AudioModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

struct Audio: Identifiable, Equatable {
  var id: UUID = .init()
  var url: URL
  var duration: Double
  var volume: Float = 1.0

  var asset: AVAsset {
    AVAsset(url: url)
  }

  mutating func setVolume(_ value: Float) {
    volume = value
  }
}
