//
//  AlbumModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/5/23.
//

import Foundation
import Photos
import UIKit

class AlbumModel {

  // MARK: Lifecycle

  init(name: String, count: Int, collection: PHAssetCollection, thumbnail: UIImage?) {
    self.name = name
    self.count = count
    self.collection = collection
    self.thumbnail = thumbnail
  }

  // MARK: Internal

  let name: String
  let count: Int
  let collection: PHAssetCollection
  var thumbnail: UIImage?
}
