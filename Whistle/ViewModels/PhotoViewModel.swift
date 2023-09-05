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
  @Published var selectedPhotos = SelectedPhotos.favorites
  @Published var isPhotoAccessAlertPresented = false


  func fetchFavorites() {
    photos.removeAll()
    let fetchOptions = PHFetchOptions()
    let imgManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true
    requestOptions.deliveryMode = .highQualityFormat
    fetchOptions.predicate = NSPredicate(format: "title = %@", "Favorites")
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    let favorites: PHFetchResult = PHAssetCollection.fetchAssetCollections(
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
    photos.removeAll()
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

  //  func listAlbums() {
  //    var album = [AlbumModel]()
  //    // albums
  //    let options = PHFetchOptions()
  //    let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
  //    userAlbums.enumerateObjects { (object: AnyObject!, _: Int, _: UnsafeMutablePointer) in
  //      if object is PHAssetCollection {
  //        let obj: PHAssetCollection = object as! PHAssetCollection
  //
  //        let fetchOptions = PHFetchOptions()
  //        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
  //        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
  //
  //        let newAlbum = AlbumModel(name: obj.localizedTitle!, count: obj.estimatedAssetCount, collection: obj)
  //        album.append(newAlbum)
  //      }
  //    }
  //    albums = album
  //    for item in albums {
  //      log(item.name)
  //    }
  //  }
  func listAlbums() {
    var albums = [AlbumModel]()

    // Fetch user albums
    let options = PHFetchOptions()
    let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)

    userAlbums.enumerateObjects { object, _, _ in
      if let albumCollection = object as? PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        // Fetch the assets (images) for the album
        let assets = PHAsset.fetchAssets(in: albumCollection, options: fetchOptions)

        // Get the first asset (image) as a thumbnail
        if let firstAsset = assets.firstObject {
          let imageManager = PHImageManager.default()
          let targetSize = CGSize(width: 100, height: 100) // Set your desired thumbnail size

          // Request the thumbnail image
          imageManager
            .requestImage(for: firstAsset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
              if let thumbnailImage = image {
                // Create an AlbumModel with the thumbnail image
                let newAlbum = AlbumModel(
                  name: albumCollection.localizedTitle ?? "",
                  count: assets.count,
                  collection: albumCollection,
                  thumbnail: thumbnailImage)
                albums.append(newAlbum)
              }
            }
        } else {
          // If the album has no images, create an AlbumModel without a thumbnail
          let newAlbum = AlbumModel(
            name: albumCollection.localizedTitle ?? "",
            count: assets.count,
            collection: albumCollection,
            thumbnail: nil)
          albums.append(newAlbum)
        }
      }
    }

    // Update your albums array
    self.albums = albums

    for item in albums {
      log(item.name)
    }
  }

}
