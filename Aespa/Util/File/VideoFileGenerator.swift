//
//  VideoFileGenerator.swift
//
//
//  Created by Young Bin on 2023/05/27.
//

import AVFoundation
import UIKit

enum VideoFileGenerator {
  static func generate(with path: URL, date: Date) -> VideoFile {
    VideoFile(
      creationDate: date,
      path: path,
      thumbnail: VideoFileGenerator.generateThumbnail(for: path) ?? UIImage())
  }

  static func generateThumbnail(for path: URL) -> UIImage? {
    let asset = AVURLAsset(url: path, options: nil)

    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    imageGenerator.apertureMode = .cleanAperture

    do {
      let cgImage = try imageGenerator.copyCGImage(
        at: CMTimeMake(value: 0, timescale: 1),
        actualTime: nil)

      let rawThumbnail = UIImage(cgImage: cgImage)
      guard let compressedData = rawThumbnail.jpegData(compressionQuality: 0.5) else {
        return nil
      }

      let thumbnail = UIImage(data: compressedData)
      return thumbnail
    } catch {
      AespaLogger.log(error: error)
      return nil
    }
  }
}
