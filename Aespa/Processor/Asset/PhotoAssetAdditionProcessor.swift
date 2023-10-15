//
//  PhotoAssetAdditionProcessor.swift
//
//
//  Created by 이영빈 on 2023/06/19.
//

import Foundation
import Photos

struct PhotoAssetAdditionProcessor: AespaAssetProcessing {
  let imageData: Data

  func process(
    _ photoLibrary: some AespaAssetLibraryRepresentable,
    _ assetCollection: some AespaAssetCollectionRepresentable)
    async throws
  {
    try await add(imageData: imageData, to: assetCollection, photoLibrary)
  }

  /// Add the photo to the app's album roll
  func add(
    imageData: Data,
    to album: some AespaAssetCollectionRepresentable,
    _ photoLibrary: some AespaAssetLibraryRepresentable)
    async throws
  {
    try await photoLibrary.performChanges {
      // Request creating an asset from the image.
      let creationRequest = PHAssetCreationRequest.forAsset()
      creationRequest.addResource(with: .photo, data: imageData, options: nil)

      // Add the asset to the desired album.
      guard
        let placeholder = creationRequest.placeholderForCreatedAsset,
        let albumChangeRequest = PHAssetCollectionChangeRequest(for: album.underlyingAssetCollection)
      else {
        Logger.log(error: AespaError.album(reason: .unabledToAccess))
        return
      }

      let enumeration = NSArray(object: placeholder)
      albumChangeRequest.addAssets(enumeration)

      Logger.log(message: "Photo is added to album")
    }
  }
}
