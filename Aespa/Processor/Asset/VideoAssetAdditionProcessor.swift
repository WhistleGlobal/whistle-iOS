//
//  VideoAssetAdditionProcessor.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import Foundation
import Photos

struct VideoAssetAdditionProcessor: AespaAssetProcessing {
  let filePath: URL

  func process(
    _ photoLibrary: some AespaAssetLibraryRepresentable,
    _ assetCollection: some AespaAssetCollectionRepresentable)
    async throws
  {
    try await add(video: filePath, to: assetCollection, photoLibrary)
  }

  /// Add the video to the app's album roll
  func add(
    video path: URL,
    to album: some AespaAssetCollectionRepresentable,
    _ photoLibrary: some AespaAssetLibraryRepresentable)
    async throws
  {
    guard album.canAdd(video: path) else {
      throw AespaError.album(reason: .notVideoURL)
    }

    return try await photoLibrary.performChanges {
      guard
        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path),
        let placeholder = assetChangeRequest.placeholderForCreatedAsset,
        let albumChangeRequest = PHAssetCollectionChangeRequest(for: album.underlyingAssetCollection)
      else {
        AespaLogger.log(error: AespaError.album(reason: .unabledToAccess))
        return
      }

      let enumeration = NSArray(object: placeholder)
      albumChangeRequest.addAssets(enumeration)

      AespaLogger.log(message: "File is added to album")
    }
  }
}
