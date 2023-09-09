//
//  APIViewModel+PostFeed.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation

import Alamofire
import AVFoundation
import SwiftyJSON
import UIKit

extension APIViewModel: PostFeedProtocol {
  // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestMyPostFeed() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/post/feed",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...300)
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

  // FIXME: - 개수 Buffer 처럼 append 하도록 수정 필요하다고 생각함, 일단 기능 테스트 후에
  func requestContentList() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/content/content-list",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
              for jsonObject in jsonArray ?? [] {
                let tempContent: MainContent = .init()
                tempContent.userId = jsonObject["user_id"] as? Int
                tempContent.userName = jsonObject["user_name"] as? String
                tempContent.profileImg = jsonObject["profile_img"] as? String
                tempContent.caption = jsonObject["caption"] as? String
                tempContent.videoUrl = jsonObject["video_url"] as? String
                tempContent.musicArtist = jsonObject["music_artist"] as? String
                tempContent.musicTitle = jsonObject["music_title"] as? String
                tempContent.musicTitle = jsonObject["music_title"] as? String
                tempContent.hashtags = jsonObject["hashtags"] as? String
                tempContent.hashtags = jsonObject["hashtags"] as? String
                tempContent.whistleCount = jsonObject["content_whistle_count"] as? Int
                tempContent.isWhistled = (jsonObject["is_whistled"] as? Int) == 0 ? false : true
                tempContent.isFollowed = (jsonObject["is_followed"] as? Int) == 0 ? false : true
                tempContent.isBookmarked = (jsonObject["is_bookmarked"] as? Int) == 0 ? false : true
                tempContent.player = AVPlayer(url: URL(string: tempContent.videoUrl ?? "")!)
                log("content url : \(tempContent.videoUrl ?? "url invalid")")
                self.contentList.append(tempContent)
              }
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
}
