//
//  UploadProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation
import UIKit

protocol UploadProtocol {
  func uploadProfilePhoto(image: UIImage, completion: @escaping (String) -> Void) async
  func uploadContent(
    video: Data,
    thumbnail: Data,
    caption: String,
    sourceURL: String,
    musicID: Int,
    videoLength: Double,
    aspectRatio: Double,
    hashtags: [String])
}
