//
//  Extension+AVAssets.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import Foundation
import SwiftUI

extension AVAsset {
  struct TrimError: Error {
    let description: String
    let underlyingError: Error?

    init(_ description: String, underlyingError: Error? = nil) {
      self.description = "TrimVideo: " + description
      self.underlyingError = underlyingError
    }
  }

  func getImage(_ second: Int, compressionQuality: Double = 0.05) -> UIImage? {
    let imgGenerator = AVAssetImageGenerator(asset: self)
    imgGenerator.appliesPreferredTrackTransform = true

    guard
      let cgImage = try? imgGenerator.copyCGImage(
        at: .init(
          seconds: Double(second),
          preferredTimescale: 1),
        actualTime: nil)
    else { return nil }
    let uiImage = UIImage(cgImage: cgImage)
    guard
      let imageData = uiImage.jpegData(compressionQuality: compressionQuality),
      let compressedUIImage = UIImage(data: imageData)
    else { return nil }
    return compressedUIImage
  }

  func videoDuration() -> Double {
    duration.seconds
  }

  func naturalSize() async -> CGSize? {
    guard let tracks = try? await loadTracks(withMediaType: .video) else { return nil }
    guard let track = tracks.first else { return nil }
    guard let size = try? await track.load(.naturalSize) else { return nil }
    return size
  }

  func adjustVideoSize(to viewSize: CGSize) async -> CGSize? {
//    guard let assetSize = await naturalSize() else { return nil }
//    let videoRatio = assetSize.width / assetSize.height
//    let isPortrait = assetSize.height > assetSize.width
    let videoSize = viewSize
//    if isPortrait {
//      videoSize = CGSize(width: videoSize.height * videoRatio, height: videoSize.height)
//    } else {
//      videoSize = CGSize(width: videoSize.width, height: videoSize.width / videoRatio)
//    }
    return videoSize
  }
}
