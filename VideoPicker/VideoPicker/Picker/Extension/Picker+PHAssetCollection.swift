//
//  Picker+PHAssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos
import UIKit
extension PHAssetCollection {

  var isCameraRoll: Bool {
    assetCollectionSubtype == .smartAlbumUserLibrary
  }

  var isAllHidden: Bool {
    assetCollectionSubtype == .smartAlbumAllHidden
  }

  var isRecentlyDeleted: Bool {
    assetCollectionSubtype.rawValue == 1000000201
  }
}

extension UIView {
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
}
