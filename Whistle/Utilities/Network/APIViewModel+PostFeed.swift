//
//  APIViewModel+MyContent.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation

import Alamofire
import AVFoundation
import Mixpanel
import SwiftyJSON
import UIKit

extension APIViewModel: PostFeedProtocol {
  // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestMyPostFeed() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/post/feed",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let decoder = JSONDecoder()
              self.myFeed = try decoder.decode([MyContent].self, from: data)
              self.myFeed = self.myFeed.filter { $0.contentId != nil }
              continuation.resume()
            } catch {
              WhistleLogger.logger.error("Error parsing JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  // FIXME: - 더미 데이터를 넣어서 테스트할 것
  func requestMyBookmark() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/post/bookmark",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let decoder = JSONDecoder()
              self.bookmark = try decoder.decode([Bookmark].self, from: data)
              continuation.resume()
            } catch {
              WhistleLogger.logger.error("Failure: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func requestMainFeed(completion: @escaping (DataResponse<[MainContent], AFError>) -> Void) {
    AF.request(
      "\(domainURL)/content/content-list",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let success):
          self.mainFeed = success
          if self.mainFeed.count > 20 {
            self.mainFeed.removeSubrange(21...)
          }
          completion(response)
        case .failure:
          WhistleLogger.logger.error("Failure")
          completion(response)
//          self.retryRequestMainFeed(completion: completion)
        }
      }
  }

  func requestMainFeedPagination(page: Int, completion: @escaping (DataResponse<[MainContent], AFError>) -> Void) {
    AF.request(
      "\(domainURL)/content/content-list/personalize/pagination?page=\(page)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let success):
          self.mainFeed = success
          completion(response)
        case .failure:
          WhistleLogger.logger.error("Failure")
          completion(response)
        }
      }
  }

//
//  func retryRequestMainFeed(completion: @escaping (DataResponse<[MainContent], AFError>) -> Void, retryCount: Int = 3) {
//    guard retryCount > 0 else {
//      // 최대 재시도 횟수 초과
//      return
//    }
//
//    // 재시도 로직: 2초 간격을 두고 다시 시도하는 방식
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//      self.requestMainFeed(completion: completion)
//    }
//  }

  // /user/post/suspend-list
  func requestReportedFeed() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/post/suspend-list",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else { return }
              let decoder = JSONDecoder()
              self.reportedContent = try decoder.decode([ReportedContent].self, from: data)
              continuation.resume()
            } catch {
              WhistleLogger.logger.error("Error parsing JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func bookmarkAction(contentID: Int, method: HTTPMethod) async -> Bool {
    if contentID == 0 { return false }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(contentID)/bookmark",
        method: method,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            if method == .post {
              Mixpanel.mainInstance().people.increment(property: "bookmark_count", by: 1)
              Mixpanel.mainInstance().track(event: "bookmark", properties: [
                "content_id": contentID,
              ])
            }
            continuation.resume(returning: true)
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume(returning: false)
          }
        }
    }
  }

  func whistleAction(contentID: Int, method: HTTPMethod) async {
    if contentID == 0 { return }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(contentID)/whistle",
        method: method,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            if method == .post {
              Mixpanel.mainInstance().people.increment(property: "whistled_count", by: 1)
              Mixpanel.mainInstance().track(event: "whistle", properties: [
                "content_id": contentID,
              ])
            }
            continuation.resume()
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func actionContentHate(contentID: Int, method: HTTPMethod) async {
    if contentID == 0 { return }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(contentID)/\(method == .post ? "hate" : "unhate")",
        method: method,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            if method == .post {
              Mixpanel.mainInstance().people.increment(property: "not_interested_count", by: 1)
              Mixpanel.mainInstance().track(event: "not_interested", properties: [
                "content_id": contentID,
              ])
            }
            continuation.resume()
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func deleteContent(contentID: Int) async {
    if contentID == 0 { return }
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/content/\(contentID)",
        method: .delete,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            continuation.resume()
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  // FIXME: - 중복신고 반환 처리하도록 추후 수정
  func reportContent(userID: Int, contentID: Int, reportReason: Int, reportDescription: String) async -> Int {
    let params: [String: Any] = [
      "user_id": "\(userID)",
      "report_reason": "\(reportReason)",
      "report_description": "\(reportDescription)",
    ]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/report/content/\(contentID)",
        method: .post,
        parameters: params,
        encoding: JSONEncoding.default,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            continuation.resume(returning: 200)
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume(returning: error.responseCode ?? 500)
          }
        }
    }
  }

  func reportUser(usedID: Int, contentID: Int, reportReason: Int, reportDescription: String) async -> Int {
    let params: [String: Any] = [
      "content_id": "\(String(describing: contentID <= 0 ? nil : contentID))",
      "report_reason": "\(reportReason)",
      "report_description": "\(reportDescription)",
    ]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/report/user/\(usedID)",
        method: .post,
        parameters: params,
        encoding: JSONEncoding.default,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            WhistleLogger.logger.debug("성공")
            continuation.resume(returning: 200)
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume(returning: error.responseCode ?? 500)
          }
        }
    }
  }

  func addViewCount(_ viewCount: ViewCount, notInclude: Set<Int>, completion: @escaping ([ViewCountModel]) -> Void) {
    do {
      let tempViewCount = viewCount
      tempViewCount.views = tempViewCount.views.filter { !notInclude.contains($0.contentId) }
      tempViewCount.views = viewCount.views.filter { Int($0.viewTime) ?? 0 >= 3 }
      tempViewCount.views = tempViewCount.views.filter { !$0.viewTime.isEmpty }
      if tempViewCount.views.isEmpty {
        return
      }
      let data = try JSONEncoder().encode(tempViewCount)
      if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        AF.request(
          "\(domainURL)/content/record-view",
          method: .post,
          parameters: dictionary,
          encoding: JSONEncoding.default,
          headers: contentTypeJson)
          .validate(statusCode: 200 ..< 300)
          .response { response in
            switch response.result {
            case .success:
              completion(tempViewCount.views)
            case .failure(let error):
              WhistleLogger.logger.error("Failure: \(error)")
            }
          }
      }
    } catch {
      WhistleLogger.logger.error("Failure: \(error)")
    }
  }

  func requestGuestFeed(completion: @escaping (DataResponse<[GuestContent], AFError>) -> Void) {
    AF.request(
      "\(domainURL)/content/all-content-list",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ..< 300)
      .responseDecodable(of: [GuestContent].self) { response in
        switch response.result {
        case .success(let success):
          self.guestFeed = success
          if self.guestFeed.count >= 10 {
            self.guestFeed.removeSubrange(10...)
          }
          completion(response)
        case .failure:
          WhistleLogger.logger.error("Error parsing JSON")
          completion(response)
        }
      }
  }

  func requestUniversalFeed(contentID: Int, completion: @escaping () -> Void) {
    if contentID == 0 { return }
    AF.request(
      "\(domainURL)/content/universal/\(contentID)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200 ... 300)
      .response { response in
        switch response.result {
        case .success(let data):
          do {
            guard let data else {
              return
            }
            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            self.mainFeed.removeAll()
            guard let singleContentJson = jsonData?["finalSingleContentRows"] as? [String: Any] else { return }
            let singleContent: MainContent = .init()
            singleContent.contentId = singleContentJson["content_id"] as? Int
            singleContent.userId = singleContentJson["user_id"] as? Int
            singleContent.userName = singleContentJson["user_name"] as? String
            singleContent.profileImg = singleContentJson["profile_img"] as? String
            singleContent.caption = singleContentJson["caption"] as? String
            singleContent.sourceURL = singleContentJson["source_url"] as? String
            singleContent.videoUrl = singleContentJson["video_url"] as? String
            singleContent.thumbnailUrl = singleContentJson["thumbnail_url"] as? String
            singleContent.musicArtist = singleContentJson["music_artist"] as? String
            singleContent.musicTitle = singleContentJson["music_title"] as? String
            singleContent.hashtags = singleContentJson["hashtags"] as? [String]
            singleContent.whistleCount = singleContentJson["content_whistle_count"] as? Int ?? 0
            singleContent.isWhistled = (singleContentJson["is_whistled"] as? Int) == 0 ? false : true
            singleContent.isFollowed = (singleContentJson["is_followed"] as? Int) == 0 ? false : true
            singleContent.isBookmarked = (singleContentJson["is_bookmarked"] as? Int) == 0 ? false : true
            singleContent.aspectRatio = singleContentJson["aspect_ratio"] as? Double ?? 0.0
            self.mainFeed.append(singleContent)

            guard let allContentsJson = jsonData?["finalAllContentRows"] as? [[String: Any]] else { return }
            for jsonObject in allContentsJson {
              let tempContent: MainContent = .init()
              tempContent.contentId = jsonObject["content_id"] as? Int
              tempContent.userId = jsonObject["user_id"] as? Int
              tempContent.userName = jsonObject["user_name"] as? String
              tempContent.profileImg = jsonObject["profile_img"] as? String
              tempContent.caption = jsonObject["caption"] as? String
              tempContent.videoUrl = jsonObject["video_url"] as? String
              tempContent.thumbnailUrl = jsonObject["thumbnail_url"] as? String
              tempContent.musicArtist = jsonObject["music_artist"] as? String
              tempContent.musicTitle = jsonObject["music_title"] as? String
              tempContent.hashtags = jsonObject["hashtags"] as? [String]
              tempContent.whistleCount = jsonObject["content_whistle_count"] as? Int ?? 0
              tempContent.isWhistled = (jsonObject["is_whistled"] as? Int) == 0 ? false : true
              tempContent.isFollowed = (jsonObject["is_followed"] as? Int) == 0 ? false : true
              tempContent.isBookmarked = (jsonObject["is_bookmarked"] as? Int) == 0 ? false : true
              tempContent.aspectRatio = jsonObject["aspect_ratio"] as? Double ?? 0.0
              self.mainFeed.append(tempContent)
            }
            completion()
          } catch {
            WhistleLogger.logger.error("Error parsing JSON: \(error)")
          }
        case .failure(let error):
          WhistleLogger.logger.error("Failure: \(error)")
        }
      }
  }

  func requestSingleContent(contentID: Int) async {
    if contentID == 0 { return }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/content/\(contentID)",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                continuation.resume()
                return
              }
              let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
              guard let singleContentJson = jsonData?["singleContent"] as? [String: Any] else { return }
              let singleContent: MainContent = .init()
              singleContent.contentId = singleContentJson["content_id"] as? Int
              singleContent.userId = singleContentJson["user_id"] as? Int
              singleContent.userName = singleContentJson["user_name"] as? String
              singleContent.profileImg = singleContentJson["profile_img"] as? String
              singleContent.caption = singleContentJson["caption"] as? String
              singleContent.sourceURL = singleContentJson["source_url"] as? String
              singleContent.videoUrl = singleContentJson["video_url"] as? String
              singleContent.thumbnailUrl = singleContentJson["thumbnail_url"] as? String
              singleContent.musicArtist = singleContentJson["music_artist"] as? String
              singleContent.musicTitle = singleContentJson["music_title"] as? String
              singleContent.hashtags = singleContentJson["hashtags"] as? [String]
              singleContent.whistleCount = singleContentJson["content_whistle_count"] as? Int ?? 0
              singleContent.isWhistled = (singleContentJson["is_whistled"] as? Int) == 0 ? false : true
              singleContent.isFollowed = (singleContentJson["is_followed"] as? Int) == 0 ? false : true
              singleContent.isBookmarked = (singleContentJson["is_bookmarked"] as? Int) == 0 ? false : true
              singleContent.aspectRatio = singleContentJson["aspect_ratio"] as? Double ?? 0.0
              self.singleContent = singleContent
              WhistleLogger.logger.debug("singleContent: \(self.singleContent.videoUrl ?? "")")
              WhistleLogger.logger.debug("singleContent: \(self.singleContent.contentId ?? 0)")
              continuation.resume()
            } catch {
              WhistleLogger.logger.error("Error parsing JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func requestMyTeamFeed(completion: @escaping (DataResponse<[MainContent], AFError>) -> Void) {
    AF.request(
      "\(domainURL)/content/content-list/myteam",
      method: .get,
      headers: contentTypeJson)
//      .validate(statusCode: 200 ... 500)
      .responseDecodable(of: [MainContent].self) { response in
        switch response.result {
        case .success(let success):
          self.myTeamFeed = success
          if self.myTeamFeed.count > 20 {
            self.myTeamFeed.removeSubrange(21...)
          }
          if self.myTeamFeed.isEmpty {
            LaunchScreenViewModel.shared.myTeamFeedDownloaded()
            LaunchScreenViewModel.shared.myTeamContentPlayerReady()
          }
          completion(response)
        case .failure:
          WhistleLogger.logger.error("Failure")
          if self.myTeamFeed.isEmpty {
            LaunchScreenViewModel.shared.myTeamFeedDownloaded()
            LaunchScreenViewModel.shared.myTeamContentPlayerReady()
          }
          completion(response)
        }
      }
  }

//  func retryRequestMyTeamFeed(completion: @escaping (DataResponse<[MainContent], AFError>) -> Void) {
//    var retryCount = 3
//    guard retryCount > 0 else {
//      // 최대 재시도 횟수 초과
//      return
//    }
//
//    // 재시도 로직: 2초 간격을 두고 다시 시도하는 방식
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//      retryCount -= 1
//      self.requestMyTeamFeed(completion: completion)
//    }
//  }

  func publisherSend() {
    publisher.send(UUID())
  }
}
