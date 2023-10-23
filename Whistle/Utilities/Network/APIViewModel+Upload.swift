//
//  APIViewModel+Upload.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import SwiftUI
import SwiftyJSON
import UIKit

extension APIViewModel: UploadProtocol {
  func uploadProfilePhoto(image: UIImage, completion: @escaping (String) -> Void) async {
    guard let image = image.jpegData(compressionQuality: 0.5) else {
      return
    }
    return await withCheckedContinuation { continuation in
      AF.upload(
        multipartFormData: { multipartFormData in
          multipartFormData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
        },
        to: "\(domainURL)/user/profile/image",
        headers: contentTypeMultipart)
        .validate(statusCode: 200 ..< 300)
        .response { response in
          switch response.result {
          case .success(let data):
            if let imageURL = String(data: data!, encoding: .utf8) {
              completion(imageURL)
              continuation.resume()
            }
          case .failure(let error):
            log("업로드 실패:, \(error)")
            continuation.resume()
          }
        }
    }
  }

  func uploadContent(
    video: Data,
    thumbnail: Data,
    caption: String,
    musicID: Int,
    videoLength: Double,
    hashtags: [String])
  {
    let params: [String: Any] = [
      "caption": caption,
      "music_id": musicID,
      "video_length": videoLength,
    ]
    AF.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(video, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
        multipartFormData.append(thumbnail, withName: "thumbnail", fileName: "thumbnail.png", mimeType: "image/png")
        for (key, value) in params {
          if let data = "\(value)".data(using: .utf8) {
            multipartFormData.append(data, withName: key)
          }
        }
        for hashtag in hashtags {
          multipartFormData.append(hashtag.data(using: .utf8)!, withName: "content_hashtags[]")
        }
      },
      to: "\(domainURL)/content/upload",
      headers: contentTypeMultipart)
      .uploadProgress { progress in
        UploadProgressViewModel.shared.progress = progress.fractionCompleted
      }
      //    .validate(statusCode: 200 ..< 501)
      .validate(statusCode: 200 ..< 300)
      .response { response in
        switch response.result {
        case .success(let data):
          UploadProgressViewModel.shared.uploadEnded()
          guard data != nil else {
            return
          }
        case .failure(let error):
          UploadProgressViewModel.shared.error = true
          log("\(error)")
        }
      }
  }
}