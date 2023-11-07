//
//  VideoQuality.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import Foundation

enum VideoQuality: Int, CaseIterable {
  case low, medium, high

  var exportPresetName: String {
    switch self {
    case .low:
      AVAssetExportPresetLowQuality
//      AVAssetExportPresetMediumQuality
    case .high, .medium:
      AVAssetExportPresetHighestQuality
    }
  }

  var title: String {
    switch self {
    case .low: "qHD - 480"
    case .medium: "HD - 720p"
    case .high: "Full HD - 1080p"
    }
  }

  var subtitle: String {
    switch self {
    case .low: "Fast loading and small size, low quality"
    case .medium: "Optimal size to quality ratio"
    case .high: "Ideal for publishing on social networks"
    }
  }

  var size: CGSize {
    switch self {
    case .low: .init(width: 854, height: 480)
    case .medium: .init(width: 1280, height: 720)
    case .high: .init(width: 1920, height: 1080)
    }
  }

  var frameRate: Double {
    switch self {
    case .low, .medium: 30
    case .high: 60
    }
  }

  var bitrate: Double {
    switch self {
    case .low: 2.5
    case .medium: 5
    case .high: 8
    }
  }

  var megaBytesPerSecond: Double {
    let totalPixels = size.width * size.height
    let bitsPerSecond = bitrate * Double(totalPixels)
    let bytesPerSecond = bitsPerSecond / 8.0 // Convert to bytes

    return bytesPerSecond / (1024 * 1024)
  }

  func calculateVideoSize(duration: Double) -> Double? {
    duration * megaBytesPerSecond
  }
}
