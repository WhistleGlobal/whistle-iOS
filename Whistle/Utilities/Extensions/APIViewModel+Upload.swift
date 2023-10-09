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
}
