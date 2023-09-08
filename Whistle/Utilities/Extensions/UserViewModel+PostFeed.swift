//
//  UserViewModel+PostFeed.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation

import Alamofire
import SwiftyJSON

extension UserViewModel: PostFeedProtocol {
  // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestMyPostFeed() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/post/feed",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let decoder = JSONDecoder()
              self.myPostFeed = try decoder.decode([PostFeed].self, from: data)
              continuation.resume()
            } catch {
              log("Error parsing JSON: \(error)")
              log("피드를 불러올 수 없습니다.")
              continuation.resume()
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestUserPostFeed(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/\(userId)/post/feed",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              self.userPostFeed = try self.decoder.decode([UserPostFeed].self, from: data)
              continuation.resume()
            } catch {
              log("Error parsing JSON: \(error)")
              log("피드를 불러올 수 없습니다.")
              continuation.resume()
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  // FIXME: - 더미 데이터를 넣어서 테스트할 것
  func requestMyBookmark() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/post/bookmark",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let json = try JSON(data: data)
              log("\(json)")
              let decoder = JSONDecoder()
              self.bookmark = try decoder.decode([Bookmark].self, from: data)
              continuation.resume()
            } catch {
              log("Error parsing JSON: \(error)")
              log("북마크를 불러올 수 없습니다.")
              continuation.resume()
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume()
          }
        }
    }
  }
}
