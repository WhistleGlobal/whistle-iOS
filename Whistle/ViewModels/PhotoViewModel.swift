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
  @Published var isPhotosEmpty = false
  @Published var selectedPhotos = SelectedPhotos.favorites
  @Published var isPhotoAccessAlertPresented = false


  func fetchFavorites() {
    let fetchOptions = PHFetchOptions()
    let imgManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true
    requestOptions.deliveryMode = .highQualityFormat
    fetchOptions.predicate = NSPredicate(format: "title = %@", "Favorites")
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    let favorites :PHFetchResult = PHAssetCollection.fetchAssetCollections(
      with: .smartAlbum,
      subtype: .smartAlbumFavorites,
      options: nil)

    var assetCollection = PHAssetCollection()

    if let firstObject = favorites.firstObject {
      assetCollection = firstObject
    }

    let photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)

    photoAssets.enumerateObjects { asset, _, _ in
      imgManager.requestImage(
        for: asset,
        targetSize: CGSize(),
        contentMode: .aspectFit,
        options: requestOptions)
      { image, _ in

        let photo = Photo(photo: Image(uiImage: image ?? UIImage()))

        self.photos.append(photo)
      }
    }
  }

  func fetchPhotos() {
    let imgManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true
    requestOptions.deliveryMode = .highQualityFormat

    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

    let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

    if fetchResult.count > 0 {
      for i in 0 ..< fetchResult.count {
        imgManager.requestImage(
          for: fetchResult.object(at: i), targetSize: CGSize(width: 100, height: 200),
          contentMode: .aspectFit,
          options: requestOptions)
        { image, _ in

          if let image {
            let photo = Photo(photo: Image(uiImage: image))
            self.photos.append(photo)
          }
        }
      }
    } else {
      DispatchQueue.main.async {
        self.isPhotosEmpty = true
      }
    }
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
            self.fetchFavorites()
          }
        }
      default:
        self.isPhotoAccessAlertPresented = true
      }
    }
  }
}
