//
//  PhotoAssetCollection.swift
//  Whistle
//
//  Created by ChoiYujin on 10/5/23.
//

import Photos

// MARK: - PhotoAssetCollection

class PhotoAssetCollection: RandomAccessCollection {
  private(set) var fetchResult: PHFetchResult<PHAsset>
  private var iteratorIndex = 0

  private var cache = [Int: PhotoAsset]()

  var startIndex: Int { 0 }
  var endIndex: Int { fetchResult.count }

  init(_ fetchResult: PHFetchResult<PHAsset>) {
    self.fetchResult = fetchResult
  }

  subscript(position: Int) -> PhotoAsset {
    if let asset = cache[position] {
      return asset
    }
    let asset = PhotoAsset(phAsset: fetchResult.object(at: position), index: position)
    cache[position] = asset
    return asset
  }

  var phAssets: [PHAsset] {
    var assets = [PHAsset]()
    fetchResult.enumerateObjects { object, _, _ in
      assets.append(object)
    }
    return assets
  }
}

// MARK: Sequence, IteratorProtocol

extension PhotoAssetCollection: Sequence, IteratorProtocol {
  func next() -> PhotoAsset? {
    if iteratorIndex >= count {
      return nil
    }

    defer {
      iteratorIndex += 1
    }

    return self[iteratorIndex]
  }
}
