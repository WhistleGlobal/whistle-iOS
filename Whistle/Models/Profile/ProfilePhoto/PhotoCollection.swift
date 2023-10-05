//
//  PhotoCollection.swift
//  Whistle
//
//  Created by ChoiYujin on 10/5/23.
//

import os.log
import Photos

// MARK: - PhotoCollection

class PhotoCollection: NSObject, ObservableObject {

  @Published var photoAssets = PhotoAssetCollection(PHFetchResult<PHAsset>())
  @Published var albums: [AlbumModel] = []

  var identifier: String? {
    assetCollection?.localIdentifier
  }

  var albumName: String?

  var smartAlbumType: PHAssetCollectionSubtype?

  let cache = CachedImageManager()

  private var assetCollection: PHAssetCollection?

  private var createAlbumIfNotFound = false

  enum PhotoCollectionError: LocalizedError {
    case missingAssetCollection
    case missingAlbumName
    case missingLocalIdentifier
    case unableToFindAlbum(String)
    case unableToLoadSmartAlbum(PHAssetCollectionSubtype)
    case addImageError(Error)
    case createAlbumError(Error)
    case removeAllError(Error)
  }

  init(albumNamed albumName: String, createIfNotFound: Bool = false) {
    self.albumName = albumName
    createAlbumIfNotFound = createIfNotFound
    super.init()
  }

  init?(albumWithIdentifier identifier: String) {
    guard let assetCollection = PhotoCollection.getAlbum(identifier: identifier) else {
      logger.error("Photo album not found for identifier: \(identifier)")
      return nil
    }
    logger.log("Loaded photo album with identifier: \(identifier)")
    self.assetCollection = assetCollection
    super.init()
    Task {
      await refreshPhotoAssets()
    }
  }

  init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
    self.smartAlbumType = smartAlbumType
    super.init()
  }

  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }

  func load() async throws {
    PHPhotoLibrary.shared().register(self)

    if let smartAlbumType {
      if let assetCollection = PhotoCollection.getSmartAlbum(subtype: smartAlbumType) {
        logger.log("Loaded smart album of type: \(smartAlbumType.rawValue)")
        self.assetCollection = assetCollection
        await refreshPhotoAssets()
        return
      } else {
        logger.error("Unable to load smart album of type: : \(smartAlbumType.rawValue)")
        throw PhotoCollectionError.unableToLoadSmartAlbum(smartAlbumType)
      }
    }

    guard let name = albumName, !name.isEmpty else {
      logger.error("Unable to load an album without a name.")
      throw PhotoCollectionError.missingAlbumName
    }

    if let assetCollection = PhotoCollection.getAlbum(named: name) {
      logger.log("Loaded photo album named: \(name)")
      self.assetCollection = assetCollection
      await refreshPhotoAssets()
      return
    }

    guard createAlbumIfNotFound else {
      logger.error("Unable to find photo album named: \(name)")
      throw PhotoCollectionError.unableToFindAlbum(name)
    }

    logger.log("Creating photo album named: \(name)")

    if let assetCollection = try? await PhotoCollection.createAlbum(named: name) {
      self.assetCollection = assetCollection
      await refreshPhotoAssets()
    }
  }

  func addImage(_ imageData: Data) async throws {
    guard let assetCollection else {
      throw PhotoCollectionError.missingAssetCollection
    }

    do {
      try await PHPhotoLibrary.shared().performChanges {
        let creationRequest = PHAssetCreationRequest.forAsset()
        if let assetPlaceholder = creationRequest.placeholderForCreatedAsset {
          creationRequest.addResource(with: .photo, data: imageData, options: nil)

          if
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection),
            assetCollection.canPerform(.addContent)
          {
            let fastEnumeration = NSArray(array: [assetPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
          }
        }
      }

      await refreshPhotoAssets()

    } catch let error {
      logger.error("Error adding image to photo library: \(error.localizedDescription)")
      throw PhotoCollectionError.addImageError(error)
    }
  }

  func removeAsset(_ asset: PhotoAsset) async throws {
    guard let assetCollection else {
      throw PhotoCollectionError.missingAssetCollection
    }

    do {
      try await PHPhotoLibrary.shared().performChanges {
        if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
          albumChangeRequest.removeAssets([asset as Any] as NSArray)
        }
      }

      await refreshPhotoAssets()

    } catch let error {
      logger.error("Error removing all photos from the album: \(error.localizedDescription)")
      throw PhotoCollectionError.removeAllError(error)
    }
  }

  func removeAll() async throws {
    guard let assetCollection else {
      throw PhotoCollectionError.missingAssetCollection
    }

    do {
      try await PHPhotoLibrary.shared().performChanges {
        if
          let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection),
          let assets = (PHAsset.fetchAssets(
            in: assetCollection,
            options: nil) as AnyObject?) as! PHFetchResult<AnyObject>?
        {
          albumChangeRequest.removeAssets(assets)
        }
      }

      await refreshPhotoAssets()

    } catch let error {
      logger.error("Error removing all photos from the album: \(error.localizedDescription)")
      throw PhotoCollectionError.removeAllError(error)
    }
  }

  private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async {
    var newFetchResult = fetchResult

    if newFetchResult == nil {
      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

      if
        let assetCollection, let fetchResult = (PHAsset.fetchAssets(
          with: fetchOptions) as AnyObject?) as? PHFetchResult<PHAsset>
      {
        newFetchResult = fetchResult
      }
    }

    if let newFetchResult {
      await MainActor.run {
        photoAssets = PhotoAssetCollection(newFetchResult)
        logger.debug("PhotoCollection photoAssets refreshed: \(self.photoAssets.count)")
      }
    }
  }

  func fetchAssetsInAlbum(albumName: String) async {
    // 먼저 앨범 이름을 사용하여 앨범을 찾습니다.
    let albumOptions = PHFetchOptions()
    albumOptions.predicate = NSPredicate(format: "title = %@", albumName)
    let albumCollection = PHAssetCollection.fetchAssetCollections(
      with: .album,
      subtype: .any,
      options: albumOptions).firstObject

    guard let album = albumCollection else {
      print("앨범을 찾을 수 없습니다.")
      return
    }

    // 앨범에 속한 이미지를 가져옵니다.
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

    let fetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)

    await MainActor.run {
      photoAssets = PhotoAssetCollection(fetchResult)
      logger.debug("앨범 '\(albumName)'의 이미지를 가져왔습니다. 이미지 수: \(self.photoAssets.count)")
    }
  }



  private static func getAlbum(identifier: String) -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: fetchOptions)
    return collections.firstObject
  }

  private static func getAlbum(named name: String) -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", name)
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    return collections.firstObject
  }

  private static func getSmartAlbum(subtype: PHAssetCollectionSubtype) -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions)
    return collections.firstObject
  }

  private static func createAlbum(named name: String) async throws -> PHAssetCollection? {
    var collectionPlaceholder: PHObjectPlaceholder?
    do {
      try await PHPhotoLibrary.shared().performChanges {
        let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        collectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
      }
    } catch let error {
      logger.error("Error creating album in photo library: \(error.localizedDescription)")
      throw PhotoCollectionError.createAlbumError(error)
    }
    logger.log("Created photo album named: \(name)")
    guard let collectionIdentifier = collectionPlaceholder?.localIdentifier else {
      throw PhotoCollectionError.missingLocalIdentifier
    }
    let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionIdentifier], options: nil)
    return collections.firstObject
  }

  func fetchAlbumList() {
    albums.removeAll()
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
  }

  func fetchPhotoByLocalIdentifier(localIdentifier: String, completion: @escaping (Photo?) -> Void) {
    let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)

    if fetchResult.count > 0 {
      let asset = fetchResult.object(at: 0)
      let imgManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.deliveryMode = .highQualityFormat

      imgManager.requestImage(
        for: asset, targetSize: CGSize(width: 800, height: 800),
        contentMode: .aspectFit,
        options: requestOptions)
      { image, _ in
        if let image {
          let photo = Photo(localIdentifier: localIdentifier, photo: image)
          DispatchQueue.main.async {
            completion(photo)
          }
        } else {
          completion(nil)
        }
      }
    } else {
      completion(nil)
    }
  }
}

// MARK: PHPhotoLibraryChangeObserver

extension PhotoCollection: PHPhotoLibraryChangeObserver {

  func photoLibraryDidChange(_ changeInstance: PHChange) {
    Task { @MainActor in
      guard let changes = changeInstance.changeDetails(for: self.photoAssets.fetchResult) else { return }
      await self.refreshPhotoAssets(changes.fetchResultAfterChanges)
    }
  }
}

private let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "PhotoCollection")
