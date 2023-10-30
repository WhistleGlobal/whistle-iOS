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

  func getImage(second: Double, compressionQuality: Double = 0.05) -> UIImage? {
    let imgGenerator = AVAssetImageGenerator(asset: self)
    imgGenerator.appliesPreferredTrackTransform = true

    guard
      let cgImage = try? imgGenerator.copyCGImage(
        at: .init(
          seconds: second,
          preferredTimescale: 1000),
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
    viewSize
  }
}
