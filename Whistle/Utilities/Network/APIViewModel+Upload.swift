//
//  APIViewModel+Upload.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import Mixpanel
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
            WhistleLogger.logger.error("Failure Upload: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func uploadContent(
    video: Data,
    thumbnail: Data,
    caption: String,
    sourceURL: String,
    musicID: Int,
    videoLength: Double,
    aspectRatio: Double = 0.0,
    hashtags: [String],
    uploadMethod: UploadMethod = .camera)
  {
    Mixpanel.mainInstance().track(event: "upload_start")
    let params: [String: Any] = [
      "caption": caption,
      "source_url": sourceURL,
      "music_id": musicID == 0 ? nil : musicID,
      "video_length": videoLength,
      "aspect_ratio": aspectRatio,
    ]
    WhistleLogger.logger.debug("\(params)")
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
        UploadProgress.shared.progress = progress.fractionCompleted
      }
      .validate(statusCode: 200 ..< 300)
      .response { response in
        switch response.result {
        case .success(let data):
          WhistleLogger.logger.debug("upload success")
          Mixpanel.mainInstance().people.set(property: "$first_upload_date", to: Date().koreaTimezone())
          Mixpanel.mainInstance().people.set(property: "last_upload_date", to: Date().koreaTimezone())
          Mixpanel.mainInstance().people.increment(property: "upload_count", by: 1)
          Mixpanel.mainInstance().track(event: "upload_complete", properties: [
            "upload_method": "\(uploadMethod.rawValue)",
            "content_caption": "\(caption)",
            "hashtags": hashtags,
            "music": musicID == 0 ? false : true,
            "content_source": "\(sourceURL)",
            "upload_date": Date().koreaTimezone(),
            "content_length": Int(videoLength),
          ])
          UploadProgress.shared.uploadEnded()
          guard data != nil else {
            return
          }
        case .failure(let error):
          UploadProgress.shared.error = true
          WhistleLogger.logger.error("Failure Upload: \(error)")
        }
      }
  }
}
