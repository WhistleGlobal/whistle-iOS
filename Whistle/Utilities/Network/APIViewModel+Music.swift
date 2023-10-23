//
//  APIViewModel+Music.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Alamofire
import Foundation
import SwiftyJSON

extension APIViewModel: MusicProtocol {
  func requestMusicList() async -> [Music] {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/content/music-list",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 500)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let decoder = JSONDecoder()
              let musicList = try decoder.decode([Music].self, from: data)

              continuation.resume(returning: musicList)
            } catch {
              log("Error parsing JSON: \(error)")
              continuation.resume(returning: [])
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume(returning: [])
          }
        }
    }
  }
}
