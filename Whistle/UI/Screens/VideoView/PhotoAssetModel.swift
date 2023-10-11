//
//  PhotoAsset.swift
//
//
//  Created by 이영빈 on 2023/07/07.
//

import Foundation
import Photos
import SwiftUI
import UIKit

// MARK: - PhotoAssetModel

/// Struct to represent a photo asset saved in the album.
public struct PhotoAssetModel {
  /// The associated `PHAsset` object from the Photos framework.
  public let asset: PHAsset

  /// The `UIImage` representation of the asset.
  public let uiimage: UIImage
}

// MARK: Identifiable

extension PhotoAssetModel: Identifiable {
  public var id: String {
    asset.localIdentifier
  }
}

// MARK: Equatable

extension PhotoAssetModel: Equatable { }

// MARK: Comparable

extension PhotoAssetModel: Comparable {
  public static func < (lhs: PhotoAssetModel, rhs: PhotoAssetModel) -> Bool {
    creationDateOfAsset(lhs.asset) > creationDateOfAsset(rhs.asset)
  }

  private static func creationDateOfAsset(_ asset: PHAsset) -> Date {
    asset.creationDate ?? Date(timeIntervalSince1970: 0)
  }
}

extension PhotoAssetModel {
  /// Transforms a `PhotoAsset` to a `PhotoFile`.
  public var toPhotoFile: PhotoFile {
    PhotoFile(
      creationDate: asset.creationDate ?? Date(timeIntervalSince1970: 0),
      image: uiimage)
  }

  /// Creates a SwiftUI `Image` from the `UIImage` of the `PhotoAsset`.
  public var image: Image {
    Image(uiImage: uiimage)
  }
}
