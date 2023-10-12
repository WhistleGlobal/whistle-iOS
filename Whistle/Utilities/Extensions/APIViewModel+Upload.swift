//
//  APIViewModel+Upload.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

extension APIViewModel: UploadProtocol {
  func uploadPhoto(image: UIImage, completion: @escaping (String) -> Void) async {
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
              log("URL: \(imageURL)")
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

  func uploadPost(
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
      //      "content_hashtags": "\(hashtags)",
    ]
    do {
//      let array = hashtags
//
//      func json(from object:Any) -> Data {
//        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
//          return Data()
//        }
//        return data
//      }
      let jsonEncoder = JSONEncoder()
      let jsonData = try jsonEncoder.encode(hashtags)
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let fileURL = documentsDirectory.appendingPathComponent("hashtags.json")

      // JSON 데이터를 파일로 저장
      try jsonData.write(to: fileURL)
      AF.upload(
        multipartFormData: { multipartFormData in
          multipartFormData.append(video, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
          multipartFormData.append(thumbnail, withName: "thumbnail", fileName: "thumbnail.png", mimeType: "image/png")
          for (key, value) in params {
            if let data = "\(value)".data(using: .utf8) {
              multipartFormData.append(data, withName: key)
            }
          }
          multipartFormData.append(jsonData, withName: "content_hashtags", mimeType: "application/json")
//          multipartFormData.append(json(from: array), withName: "tagJSON")
//          print(multipartFormData)
        },
        to: "\(domainURL)/content/upload",
        headers: contentTypeMultipart)
        .uploadProgress { progress in
          print("Upload Progress: \(progress.fractionCompleted)")
        }
        //    .validate(statusCode: 200 ..< 501)
        .validate(statusCode: 200 ..< 300)
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
    } catch {
      print("JSON ERROR")
    }
  }
}
