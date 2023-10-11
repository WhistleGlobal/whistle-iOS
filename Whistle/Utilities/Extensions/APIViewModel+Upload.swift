//
//  APIViewModel+Upload.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import UIKit

extension APIViewModel: UploadProtocol {
  func uploadPhoto(image: UIImage, completion: @escaping (String) -> Void) async {
    guard let image = image.jpegData(compressionQuality: 0.5) else {
      return
    }
    return await withCheckedContinuation { continuation in
      AF.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      }, to: "\(domainURL)/user/profile/image", headers: contentTypeMultipart)
        .validate(statusCode: 200..<300)
        .response { response in
          switch response.result {
          case .success(let data):
            if let imageUrl = String(data: data!, encoding: .utf8) {
              log("URL: \(imageUrl)")
              completion(imageUrl)
              continuation.resume()
            }
          case .failure(let error):
            log("업로드 실패:, \(error)")
            continuation.resume()
          }
        }
    }
  }

  func uploadPost(
    video: String,
    thumbnail: String,
    caption: String,
    musicID: Int,
    videoLength: Double,
    hashtags: [String])
  {
    let params: [String: Any] = [
      "video" : "\(video)",
      "thumbnail" : "\(thumbnail)",
      "caption" : "\(caption)",
      "music_id" : "\(musicID)",
      "video_length" : "\(videoLength)",
      "content_hashtags" : "\(hashtags)",
    ]

    AF.request(
      "\(domainURL)/content/upload",
      method: .post,
      parameters: params,
      headers: contentTypeMultipart)
      .validate(statusCode: 200...500)
      .response { response in
        switch response.result {
        case .success(let data):
          guard let data else {
            return
          }
          log("Success: \(data)")
        case .failure(let error):
          log("\(error)")
        }
      }
  }
}
