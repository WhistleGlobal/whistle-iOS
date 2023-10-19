//
//  AespaCoreAlbumManager.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import Photos

// MARK: - AespaCoreAlbumManager

/// Retreive the video(url) from `FileManager` based local storage
/// and add the video to the pre-defined album roll
class AespaCoreAlbumManager {
  // Dependencies
  private let cachingProxy: AssetCachingProxy
  private let photoLibrary: PHPhotoLibrary
  private let albumName: String
  private var album: PHAssetCollection?

  convenience init(albumName: String) {
    let photoLibrary = PHPhotoLibrary.shared()
    let cachingProxy = AssetCachingProxy()
    self.init(albumName: albumName, cachingProxy, photoLibrary)
  }

  init(
    albumName: String,
    _ cachingProxy: AssetCachingProxy,
    _ photoLibrary: PHPhotoLibrary)
  {
    self.cachingProxy = cachingProxy
    self.albumName = albumName
    self.photoLibrary = photoLibrary
  }

//  func run(processor: some AespaAssetProcessing) async throws {
  ////    guard
  ////      case .authorized = await photoLibrary.requestAuthorization(for: .addOnly)
  ////    else {
  ////      let error = AespaError.album(reason: .unabledToAccess)
  ////      Logger.log(error: error)
  ////      throw error
  ////    }
//
  ////    if let album {
  ////      try await processor.process(photoLibrary, album)
  ////    } else {
  ////      album = try AlbumImporter.getAlbum(name: albumName, in: photoLibrary)
  ////      try await run(processor: processor)
  ////    }
//  }
//
//  func run<T: AespaAssetLoading>(loader: T) async throws -> T.ReturnType {
  ////    guard
  ////      case .authorized = await photoLibrary.requestAuthorization(for: .readWrite)
  ////    else {
  ////      let error = AespaError.album(reason: .unabledToAccess)
  ////      Logger.log(error: error)
  ////      throw error
  ////    }
//
//    if let album {
//      return try loader.load(photoLibrary, album)
//    } else {
//      album = try AlbumImporter.getAlbum(name: albumName, in: photoLibrary)
//      return try await run(loader: loader)
//    }
//  }
}

extension AespaCoreAlbumManager {
  func addToAlbum(filePath: URL) async throws {
    let processor = VideoAssetAdditionProcessor(filePath: filePath)
//    try await run(processor: processor)
  }

  func addToAlbum(imageData: Data) async throws {
    let processor = PhotoAssetAdditionProcessor(imageData: imageData)
//    try await run(processor: processor)
  }

//  func fetchPhotoFile(limit: Int) async -> [PhotoAsset] {
//    let loader = AssetLoader(limit: limit, assetType: .image)
//
//    do {
  ////      let assets = try await run(loader: loader)
  ////      return await cachingProxy.fetchPhoto(assets)
//    } catch {
//      Logger.log(error: error)
//      return []
//    }
//  }

//  func fetchVideoFile(limit: Int) async -> [VideoAsset] {
//    let processor = AssetLoader(limit: limit, assetType: .video)
//
//    do {
  ////      let assets = try await run(loader: processor)
  ////      return await cachingProxy.fetchVideo(assets)
//    } catch {
//      Logger.log(error: error)
//      return []
//    }
//  }
}
