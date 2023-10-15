//
//  AssetLoader.swift
//
//
//  Created by Young Bin on 2023/07/03.
//

import Foundation
import Photos

struct AssetLoader: AespaAssetLoading {
  let limit: Int
  let assetType: PHAssetMediaType

  func load(
    _: some AespaAssetLibraryRepresentable,
    _ assetCollection: some AespaAssetCollectionRepresentable) throws -> [PHAsset]
  {
    let fetchOptions = PHFetchOptions()
    fetchOptions.fetchLimit = limit
    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", assetType.rawValue)
    fetchOptions.sortDescriptors = [
      NSSortDescriptor(
        key: "creationDate",
        ascending: false),
    ]

    guard let assetCollection = assetCollection as? PHAssetCollection else {
      fatalError("Asset collection doesn't conform to PHAssetCollection")
    }

    var assets = [PHAsset]()
    let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
    assetsFetchResult.enumerateObjects { asset, _, _ in
      assets.append(asset)
    }

    return assets
  }
}
