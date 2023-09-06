//
//  PhotoViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/5/23.
//

import Foundation
import Photos
import SwiftUI

class PhotoViewModel: ObservableObject {

  enum SelectedPhotos: Int {
    case all = 1
    case favorites = 0
  }

  @Published var photos: [Photo] = []
  @Published var albums: [AlbumModel] = []
  @Published var isPhotosEmpty = false
  @Published var isPhotoAccessAlertPresented = false
  @Published var fetchPhotosWorkItem: DispatchWorkItem?

  func fetchPhotos() {
    fetchPhotosWorkItemCancel()
    photos.removeAll()
    fetchPhotosWorkItem = DispatchWorkItem { [weak self] in
      guard let self else { return }

      let imgManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.deliveryMode = .highQualityFormat

      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

      if fetchResult.count > 0 {
        for i in 0 ..< fetchResult.count {
          if fetchPhotosWorkItem?.isCancelled == true {
            return
          }

          imgManager.requestImage(
            for: fetchResult.object(at: i), targetSize: CGSize(width: 800, height: 800),
            contentMode: .aspectFit,
            options: requestOptions)
          { image, _ in

            if let image {
              let photo = Photo(photo: Image(uiImage: image))

              DispatchQueue.main.async {
                self.photos.append(photo)
              }
            }
          }
        }
      } else {
        DispatchQueue.main.async {
          self.isPhotosEmpty = true
        }
      }
    }
    guard let fetchPhotosWorkItem else {
      log("guard")
      return
    }
    DispatchQueue.global().async(execute: fetchPhotosWorkItem)
  }

  func requestAuthorizationAndFetchPhotos(selectedPhotos: SelectedPhotos) {
    PHPhotoLibrary.requestAuthorization { status in
      switch status {
      case .authorized:
        DispatchQueue.main.async {
          switch selectedPhotos {
          case .all:
            self.fetchPhotos()
          case .favorites:
            self.fetchPhotos()
          }
        }
      default:
        self.isPhotoAccessAlertPresented = true
      }
    }
  }

  func listAlbums() {
    fetchPhotosWorkItem?.cancel()
    var albums = [AlbumModel]()

    let options = PHFetchOptions()
    let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)

    userAlbums.enumerateObjects { object, _, _ in
      if let albumCollection = object as? PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        let assets = PHAsset.fetchAssets(in: albumCollection, options: fetchOptions)

        if let firstAsset = assets.firstObject {
          let imageManager = PHImageManager.default()
          let targetSize = CGSize(width: 300, height: 300)

          imageManager
            .requestImage(
              for: firstAsset,
              targetSize: targetSize,
              contentMode: .aspectFit,
              options: nil)
          { image, _ in
            if let thumbnailImage = image {
              let newAlbum = AlbumModel(
                name: albumCollection.localizedTitle ?? "",
                count: assets.count,
                collection: albumCollection,
                thumbnail: thumbnailImage)
              albums.append(newAlbum)
            }
          }
        } else {
          let newAlbum = AlbumModel(
            name: albumCollection.localizedTitle ?? "",
            count: assets.count,
            collection: albumCollection,
            thumbnail: nil)
          albums.append(newAlbum)
        }
      }
    }

    self.albums = albums

    for item in albums {
      log(item.name)
    }
  }

  func fetchAlbumPhotos(albumName: String) {
    fetchPhotosWorkItemCancel()

    photos.removeAll()
    fetchPhotosWorkItem = DispatchWorkItem { [weak self] in
      guard let self else { return }

      let fetchOptions = PHFetchOptions()
      fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
      let album = PHAssetCollection.fetchAssetCollections(
        with: .album,
        subtype: .any,
        options: fetchOptions).firstObject

      guard let targetAlbum = album else {
        return
      }

      let imgManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.deliveryMode = .highQualityFormat

      let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: targetAlbum, options: nil)

      if fetchResult.count > 0 {
        for i in 0 ..< fetchResult.count {
          if fetchPhotosWorkItem?.isCancelled == true {
            return
          }

          imgManager.requestImage(
            for: fetchResult.object(at: i), targetSize: CGSize(width: 800, height: 800),
            contentMode: .aspectFit,
            options: requestOptions)
          { image, _ in
            if let image {
              let photo = Photo(photo: Image(uiImage: image))
              DispatchQueue.main.async {
                self.photos.append(photo)
              }
            }
          }
        }
      } else {
        DispatchQueue.main.async {
          self.isPhotosEmpty = true
        }
      }
    }
    guard let fetchPhotosWorkItem else {
      log("guard")
      return
    }
    DispatchQueue.global(qos: .background).async(execute: fetchPhotosWorkItem)
  }

  func fetchPhotosWorkItemCancel() {
    if let fetchPhotosWorkItem {
      fetchPhotosWorkItem.cancel()
    }
  }
}
