//
//  AlbumImporter.swift
//
//
//  Created by Young Bin on 2023/05/27.
//

import Foundation

import Photos
import UIKit

struct AlbumImporter {
  private static let lock = NSRecursiveLock()

  static func getAlbum<
    Collection: AespaAssetCollectionRepresentable
  >(
    name: String,
    in photoLibrary: some AespaAssetLibraryRepresentable,
    retry: Bool = true,
    _ fetchOptions: PHFetchOptions = .init())
    throws -> Collection
  {
    lock.lock()
    defer { lock.unlock() }

    let album: Collection? = photoLibrary.fetchAlbum(title: name, fetchOptions: fetchOptions)

    if let album {
      return album
    } else if retry {
      try createAlbum(name: name, in: photoLibrary)
      return try getAlbum(name: name, in: photoLibrary, retry: false, fetchOptions)
    } else {
      throw AespaError.album(reason: .unabledToAccess)
    }
  }

  private static func createAlbum(
    name: String,
    in photoLibrary: some AespaAssetLibraryRepresentable)
    throws
  {
    lock.lock()
    defer { lock.unlock() }

    try photoLibrary.performChangesAndWait {
      PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
    }

    Logger.log(message: "The album \(name) is created.")
  }
}
