//
//  File.swift
//
//
//  Created by 이영빈 on 2023/06/16.
//

import Foundation
import Photos

// MARK: - AespaAssetLibraryRepresentable

protocol AespaAssetLibraryRepresentable {
  func performChanges(_ changes: @escaping () -> Void) async throws
  func performChangesAndWait(_ changeBlock: @escaping () -> Void) throws
  func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus

  func fetchAlbum<Collection: AespaAssetCollectionRepresentable>(
    title: String,
    fetchOptions: PHFetchOptions) -> Collection?
}

// MARK: - AespaAssetCollectionRepresentable

protocol AespaAssetCollectionRepresentable {
  var underlyingAssetCollection: PHAssetCollection { get }
  var localizedTitle: String? { get }

  func canAdd(video filePath: URL) -> Bool
}

// MARK: - PHPhotoLibrary + AespaAssetLibraryRepresentable

extension PHPhotoLibrary: AespaAssetLibraryRepresentable {
  func fetchAlbum<Collection: AespaAssetCollectionRepresentable>(
    title: String,
    fetchOptions: PHFetchOptions)
    -> Collection?
  {
    fetchOptions.predicate = NSPredicate(format: "title = %@", title)
    let collections = PHAssetCollection.fetchAssetCollections(
      with: .album, subtype: .any, options: fetchOptions)

    return collections.firstObject as? Collection
  }

  func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: accessLevel)
  }
}

// MARK: - PHAssetCollection + AespaAssetCollectionRepresentable

extension PHAssetCollection: AespaAssetCollectionRepresentable {
  var underlyingAssetCollection: PHAssetCollection { self }

  func canAdd(video filePath: URL) -> Bool {
    let asset = AVAsset(url: filePath)
    let tracks = asset.tracks(withMediaType: AVMediaType.video)

    return !tracks.isEmpty
  }
}
