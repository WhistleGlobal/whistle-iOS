//
//  File.swift
//
//
//  Created by 이영빈 on 2023/07/07.
//

import AVFoundation
import Photos
import SwiftUI
import UIKit

// MARK: - VideoAssetModel

/// Struct to represent a video asset saved in the album.
public struct VideoAssetModel {
  /// The associated `PHAsset` object from the Photos framework.
  private let phAsset: PHAsset

  /// The `AVAsset` representation of the video.
  public let asset: AVAsset

  /// The `UIImage` thumbnail of the video.
  public let thumbnail: UIImage

  init(phAsset: PHAsset, asset: AVAsset, thumbnail: UIImage) {
    self.phAsset = phAsset
    self.asset = asset
    self.thumbnail = thumbnail
  }
}

// MARK: Identifiable

extension VideoAssetModel: Identifiable {
  /// ID is determined by the local identifier of the `PHAsset`.
  public var id: String {
    phAsset.localIdentifier
  }
}

// MARK: Equatable

extension VideoAssetModel: Equatable { }

// MARK: Comparable

extension VideoAssetModel: Comparable {
  /// Defines the logic to compare two `VideoAsset` instances.
  public static func < (lhs: VideoAssetModel, rhs: VideoAssetModel) -> Bool {
    creationDateOfAsset(lhs.phAsset) > creationDateOfAsset(rhs.phAsset)
  }

  private static func creationDateOfAsset(_ asset: PHAsset) -> Date {
    asset.creationDate ?? Date(timeIntervalSince1970: 0)
  }
}

extension VideoAssetModel {
  /// Transforms a `VideoAsset` to a `VideoFile`.
  public var toVideoFile: VideoFile {
    VideoFile(
      creationDate: phAsset.creationDate ?? Date(timeIntervalSince1970: 0),
      path: nil,
      thumbnail: thumbnail)
  }

  /// Creates a SwiftUI `Image` from the thumbnail `UIImage` of the `VideoAsset`.
  public var thumbnailImage: Image {
    Image(uiImage: thumbnail)
  }
}
