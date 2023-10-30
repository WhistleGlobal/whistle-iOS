//
//  PickerManager+Photo.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Kingfisher
import MobileCoreServices
import Photos
import UIKit

// MARK: - _PhotoFetchOptions

struct _PhotoFetchOptions {
  let sizeMode: PhotoSizeMode
  let resizeMode: PHImageRequestOptionsResizeMode
  let version: PHImageRequestOptionsVersion
  let needCache: Bool
  let isNetworkAccessAllowed: Bool
  let progressHandler: PHAssetImageProgressHandler?

  init(
    sizeMode: PhotoSizeMode = .thumbnail(100),
    resizeMode: PHImageRequestOptionsResizeMode = .fast,
    version: PHImageRequestOptionsVersion = .current,
    needCache: Bool = true,
    isNetworkAccessAllowed: Bool = true,
    progressHandler: PHAssetImageProgressHandler? = nil)
  {
    self.sizeMode = sizeMode
    self.resizeMode = resizeMode
    self.version = version
    self.needCache = needCache
    self.isNetworkAccessAllowed = isNetworkAccessAllowed
    self.progressHandler = progressHandler
  }

  var targetSize: CGSize {
    switch sizeMode {
    case .thumbnail(let width):
      CGSize(width: width, height: width)
    case .preview(let width):
      CGSize(width: width, height: width)
    case .original:
      PHImageManagerMaximumSize
    }
  }
}

// MARK: - PhotoSizeMode

enum PhotoSizeMode: Equatable {
  /// Thumbnail Size
  case thumbnail(CGFloat)
  /// Preview Size, based on your config
  case preview(CGFloat)
  /// Original Size
  case original
}

typealias _PhotoFetchCompletion = (Result<PhotoFetchResponse, AnyImageError>) -> Void
typealias _PhotoDataFetchCompletion = (Result<PhotoDataFetchResponse, AnyImageError>) -> Void
typealias _PhotoLiveFetchCompletion = (Result<PhotoLiveFetchResponse, AnyImageError>) -> Void

extension PickerManager {
  func requestPhoto(for album: Album, completion: @escaping _PhotoFetchCompletion) {
    if let asset = options.orderByDate == .asc ? album.assets.last : album.assets.first {
      let phAsset: PHAsset
      if
        asset.isCamera, let secondAsset = options.orderByDate == .asc
        ? album.assets.dropLast().last
        : album.assets.dropFirst().first
      {
        phAsset = secondAsset.phAsset
      } else {
        phAsset = asset.phAsset
      }
      let options = _PhotoFetchOptions(sizeMode: .thumbnail(100 * UIScreen.main.nativeScale), needCache: false)
      requestPhoto(for: phAsset, options: options, completion: completion)
    }
  }

  func savePhoto(image: UIImage, completion: PhotoSaveCompletion? = nil) {
    ExportTool.savePhoto(image: image, completion: completion)
  }

  func savePhoto(url: URL, completion: PhotoSaveCompletion? = nil) {
    ExportTool.savePhoto(url: url, completion: completion)
  }
}

// MARK: - Request photo

extension PickerManager {
  func requestPhoto(
    for asset: PHAsset,
    options: _PhotoFetchOptions = .init(),
    completion: @escaping _PhotoFetchCompletion)
  {
    let fetchOptions = PhotoFetchOptions(
      size: options.targetSize,
      resizeMode: options.resizeMode,
      version: options.version,
      isNetworkAccessAllowed: options.isNetworkAccessAllowed,
      progressHandler: options.progressHandler)
    let requestID = ExportTool.requestPhoto(for: asset, options: fetchOptions) { result, requestID in
      switch result {
      case .success(let response):
        switch options.sizeMode {
        case .original:
          completion(.success(.init(image: response.image, isDegraded: response.isDegraded)))
        case .preview:
          self.workQueue.async { [weak self] in
            guard let self else { return }
            resizeSemaphore.wait()
            let resizedImage = UIImage.resize(from: response.image, limitSize: options.targetSize, isExact: true)
            resizeSemaphore.signal()
            if !response.isDegraded, options.needCache {
              cache.store(resizedImage, forKey: asset.localIdentifier)
            }
            DispatchQueue.main.async {
              completion(.success(.init(image: resizedImage, isDegraded: response.isDegraded)))
            }
          }
        case .thumbnail:
          if !response.isDegraded, options.needCache {
            self.cache.store(response.image, forKey: asset.localIdentifier)
          }
          completion(.success(.init(image: response.image, isDegraded: response.isDegraded)))
        }
      case .failure(let error):
        guard error == .cannotFindInLocal, options.isNetworkAccessAllowed else {
          completion(.failure(error))
          return
        }
        // Download image from iCloud
        let photoDataOptions = PhotoDataFetchOptions(
          version: options.version,
          isNetworkAccessAllowed: options.isNetworkAccessAllowed,
          progressHandler: options.progressHandler)
        self.workQueue.async { [weak self] in
          guard let self else { return }
          requestPhotoData(for: asset, options: photoDataOptions) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
              switch options.sizeMode {
              case .original:
                guard let image = UIImage(data: response.data) else {
                  DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                  }
                  return
                }
                DispatchQueue.main.async {
                  completion(.success(.init(image: image, isDegraded: false)))
                }
              case .preview:
                resizeSemaphore.wait()
                guard let resizedImage = UIImage.resize(from: response.data, limitSize: options.targetSize) else {
                  resizeSemaphore.signal()
                  DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                  }
                  return
                }
                resizeSemaphore.signal()
                cache.store(resizedImage, forKey: asset.localIdentifier)
                DispatchQueue.main.async {
                  completion(.success(.init(image: resizedImage, isDegraded: false)))
                }
              case .thumbnail:
                guard let resizedImage = UIImage.resize(from: response.data, limitSize: options.targetSize) else {
                  DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                  }
                  return
                }
                DispatchQueue.main.async {
                  completion(.success(.init(image: resizedImage, isDegraded: false)))
                }
              }
            case .failure(let error):
              DispatchQueue.main.async {
                completion(.failure(error))
              }
            }
          }
        }
      }
      self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    enqueueFetch(for: asset.localIdentifier, requestID: requestID)
  }
}

// MARK: - Request photo data

extension PickerManager {
  func requestPhotoData(
    for asset: PHAsset,
    options: PhotoDataFetchOptions = .init(),
    completion: @escaping (_PhotoDataFetchCompletion))
  {
    let requestID = ExportTool.requestPhotoData(for: asset, options: options) { result, requestID in
      completion(result)
      self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    enqueueFetch(for: asset.localIdentifier, requestID: requestID)
  }
}

// MARK: - Request photo live

extension PickerManager {
  func requestPhotoLive(
    for asset: PHAsset,
    options: PhotoLiveFetchOptions = .init(),
    completion: @escaping _PhotoLiveFetchCompletion)
  {
    let requestID = ExportTool.requestPhotoLive(for: asset, options: options) { result, requestID in
      completion(result)
      self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    enqueueFetch(for: asset.localIdentifier, requestID: requestID)
  }
}
