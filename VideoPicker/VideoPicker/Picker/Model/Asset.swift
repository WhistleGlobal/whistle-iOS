//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos
import UIKit

// MARK: - Asset

public class Asset: IdentifiableResource {
  /// PHAsset
  public let phAsset: PHAsset
  public let mediaType: MediaType

  var _images: [ImageKey: UIImage] = [:]
  var videoDidDownload = false

  var idx: Int
  var state: State = .unchecked
  var selectedNum = 1

  public var identifier: String {
    phAsset.localIdentifier
  }

  init(idx: Int, asset: PHAsset, selectOptions: PickerSelectOption) {
    self.idx = idx
    phAsset = asset
    mediaType = MediaType(asset: asset, selectOptions: selectOptions)
  }
}

extension Asset {
  public var image: UIImage {
    _image ?? .init()
  }

  var _image: UIImage? {
    (_images[.output] ?? _images[.edited]) ?? _images[.initial]
  }

  var duration: TimeInterval {
    phAsset.duration
  }

  var durationDescription: String {
    let time = Int(duration)
    let min = time / 60
    let sec = time % 60
    return String(format: "%02ld:%02ld", min, sec)
  }

  var isReady: Bool {
    switch mediaType {
    case .photo, .photoLive:
      _image != nil
    case .video:
      videoDidDownload
    }
  }

  var isCamera: Bool {
    idx == Asset.cameraItemIDx
  }

  static let cameraItemIDx: Int = -1
}

// MARK: CustomStringConvertible

extension Asset: CustomStringConvertible {
  public var description: String {
    "<Asset> \(identifier) mediaType=\(mediaType) image=\(image)"
  }
}

// MARK: - State

extension Asset {
  enum State: Equatable {
    case unchecked
    case normal
    case selected
    case disable(AssetDisableCheckRule)

    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.unchecked, unchecked):
        true
      case (.normal, normal):
        true
      case (.selected, selected):
        true
      case (.disable, disable):
        true
      default:
        false
      }
    }
  }

  var isUnchecked: Bool {
    state == .unchecked || state == .normal
  }

  var isSelected: Bool {
    state == .selected
  }

  var isDisable: Bool {
    switch state {
    case .disable:
      true
    default:
      false
    }
  }
}

// MARK: - Disable Check

extension Asset {
  func check(disable rules: [AssetDisableCheckRule], assetList: [Asset]) {
    for rule in rules {
      if rule.isDisable(for: self, assetList: assetList) {
        state = .disable(rule)
        return
      }
    }
    if state != .selected {
      state = .normal
    }
  }
}

// MARK: - Original Photo

extension Asset {
  /// Fetch Photo Data
  /// - Note: Only for `MediaType` Photo, LivePhoto
  /// - Parameter options: Photo Data Fetch Options
  /// - Parameter completion: Photo Data Fetch Completion
  @discardableResult
  public func fetchPhotoData(
    options: PhotoDataFetchOptions = .init(),
    completion: @escaping PhotoDataFetchCompletion)
    -> PHImageRequestID
  {
    guard phAsset.mediaType == .image else {
      completion(.failure(.invalidMediaType), 0)
      return 0
    }
    return ExportTool.requestPhotoData(for: phAsset, options: options, completion: completion)
  }

  /// Fetch Photo URL
  /// - Note: Only for `MediaType` Photo
  /// - Parameter options: Photo URL Fetch Options
  /// - Parameter completion: Photo URL Fetch Completion
  @discardableResult
  public func fetchPhotoURL(
    options: PhotoURLFetchOptions = .init(),
    completion: @escaping PhotoURLFetchCompletion)
    -> PHImageRequestID
  {
    guard phAsset.mediaType == .image else {
      completion(.failure(.invalidMediaType), 0)
      return 0
    }
    return ExportTool.requestPhotoURL(for: phAsset, options: options, completion: completion)
  }
}

// MARK: - Video

extension Asset {
  /// Fetch Video
  /// - Note: Only for `MediaType` Video
  /// - Parameter options: Video Fetch Options
  /// - Parameter completion: Video Fetch Completion
  @discardableResult
  public func fetchVideo(
    options: VideoFetchOptions = .init(),
    completion: @escaping VideoFetchCompletion)
    -> PHImageRequestID
  {
    guard phAsset.mediaType == .video else {
      completion(.failure(.invalidMediaType), 0)
      return 0
    }
    return ExportTool.requestVideo(for: phAsset, options: options, completion: completion)
  }

  /// Fetch Video URL
  /// - Note: Only for `MediaType` Video
  /// - Parameter options: Video URL Fetch Options
  /// - Parameter completion: Video URL Fetch Completion
  @discardableResult
  public func fetchVideoURL(
    options: VideoURLFetchOptions = .init(),
    completion: @escaping VideoURLFetchCompletion)
    -> PHImageRequestID
  {
    guard phAsset.mediaType == .video else {
      completion(.failure(.invalidMediaType), 0)
      return 0
    }
    return ExportTool.requestVideoURL(for: phAsset, options: options, completion: completion)
  }
}

// MARK: Asset.ImageKey

extension Asset {
  enum ImageKey: String, Hashable {
    case thumbnail
    case initial
    case edited
    case output
  }
}
