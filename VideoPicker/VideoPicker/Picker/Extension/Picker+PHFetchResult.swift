//
//  Picker+PHFetchResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PHFetchResult where ObjectType == PHAssetCollection {
  func objects() -> [PHAssetCollection] {
    var results = [PHAssetCollection]()
    enumerateObjects { object, _, _ in
      results.append(object)
    }
    return results
  }
}

extension PHFetchResult where ObjectType == PHCollection {
  func objects() -> [PHCollection] {
    var results = [PHCollection]()
    enumerateObjects { object, _, _ in
      results.append(object)
    }
    return results
  }
}

extension PHFetchResult where ObjectType == PHAsset {
  func objects() -> [PHAsset] {
    var results = [PHAsset]()
    enumerateObjects { object, _, _ in
      results.append(object)
    }
    return results
  }
}
