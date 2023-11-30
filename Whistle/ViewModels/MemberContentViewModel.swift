//
//  MemberContentViewModel.swift
//  Whistle
//
//  Created by 박상원 on 11/25/23.
//

import Alamofire
import AVFoundation
import KeychainSwift
import SwiftUI

// MARK: - MemberContentViewModel

class MemberContentViewModel: ObservableObject {
  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0
  @Published var memberProfile = MemberProfile()
  @Published var memberWhistleCount = 0
  @Published var memberFollow = MemberFollow()
  @Published var memberFeed: [MemberContent] = []
  let feedProgress = MemberContentProgress()
  let profileProgress = MemberContentProgress()
  let whistleCountProgress = MemberContentProgress()
  let decoder = JSONDecoder()
  let keychain = KeychainSwift()
  var idToken: String {
    guard let idTokenKey = keychain.get("id_token") else {
      WhistleLogger.logger.debug("id_token nil")
      return ""
    }
    return idTokenKey
  }

  var domainURL: String {
    AppKeys.domainURL as! String
  }

  var contentTypeJson: HTTPHeaders {
    [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
  }

  var contentTypeXwwwForm: HTTPHeaders {
    [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/x-www-form-urlencoded",
    ]
  }

  var contentTypeMultipart: HTTPHeaders {
    [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "multipart/form-data",
    ]
  }

  func requestMemberProfile(userID: Int) async {
    profileProgress.changeDownloadState(state: .downloading)
    if userID == 0 {
      return
    }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/\(userID)/profile",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .responseDecodable(of: MemberProfile.self) { response in
          switch response.result {
          case .success(let success):
            self.memberProfile = success
            continuation.resume()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.profileProgress.changeDownloadState(state: .finished)
//            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
            self.profileProgress.changeDownloadState(state: .finished)
          }
        }
    }
  }

  func requestMemberWhistlesCount(userID: Int) async {
    if userID == 0 {
      return
    }
    whistleCountProgress.changeDownloadState(state: .downloading)
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/\(userID)/whistle/count",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ..< 300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let responseData = data else {
              return
            }
            do {
              if
                let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                let count = jsonObject["whistle_all_count"] as? Int
              {
                self.memberWhistleCount = count
                continuation.resume()
              }
            } catch {
              WhistleLogger.logger.error("Error parsing JSON: \(error)")
              continuation.resume()
            }
            self.whistleCountProgress.changeDownloadState(state: .finished)
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            self.whistleCountProgress.changeDownloadState(state: .finished)
          }
        }
    }
  }

  func requestMemberFollow(userID: Int) async {
    if userID == 0 {
      return
    }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/\(userID)/follow-list",
        method: .get,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              self.memberFollow = try self.decoder.decode(MemberFollow.self, from: data ?? .init())
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

  // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestMemberPostFeed(userID: Int) async {
    feedProgress.changeDownloadState(state: .downloading)
    if userID == 0 { return }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/\(userID)/post/feed",
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
              self.memberFeed = try self.decoder.decode([MemberContent].self, from: data)
              continuation.resume()
            } catch {
              WhistleLogger.logger.error("Error parsing JSON: \(error)")
              continuation.resume()
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.feedProgress.changeDownloadState(state: .finished)
//            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            self.memberFeed = []
            continuation.resume()
            self.feedProgress.changeDownloadState(state: .finished)
          }
        }
    }
  }
}

extension MemberContentViewModel {
  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), memberFeed.count - 1)
    if index == memberFeed.count - 1 {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      currentPlayer?.seek(to: .zero)
      if memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: memberFeed[index + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
    }
  }

  func goPlayerPrev() {
    if currentVideoIndex == 0 {
      stopPlayer()
      nextPlayer = nil
      nextPlayer = currentPlayer
      currentPlayer = nil
      currentPlayer = prevPlayer
      prevPlayer = nil
      currentPlayer?.seek(to: .zero)
      if memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
      return
    }
    stopPlayer()
    nextPlayer = nil
    nextPlayer = currentPlayer
    currentPlayer = nil
    currentPlayer = prevPlayer
    prevPlayer = nil
    if currentVideoIndex != 0 {
      prevPlayer = AVPlayer(url: URL(string: memberFeed[currentVideoIndex - 1].videoUrl ?? "")!)
    }
    currentPlayer?.seek(to: .zero)
    if memberFeed[currentVideoIndex].isHated {
      return
    }
    currentPlayer?.play()
  }

  func stopPlayer() {
    if prevPlayer != nil {
      prevPlayer?.seek(to: .zero)
      prevPlayer?.pause()
    }
    if currentPlayer != nil {
      currentPlayer?.seek(to: .zero)
      currentPlayer?.pause()
    }
    if nextPlayer != nil {
      nextPlayer?.seek(to: .zero)
      nextPlayer?.pause()
    }
  }

  func resetPlayer() {
    prevPlayer = nil
    currentPlayer = nil
    nextPlayer = nil
  }

  func initialPlayers() {
    if memberFeed.isEmpty { return }
    guard let urlString = memberFeed.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if memberFeed.count < 2 { return }
    let urlStringNext = memberFeed[1].videoUrl
    nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
  }

  func initialPlayers(index: Int) {
    if memberFeed.isEmpty { return }
    if memberFeed.count == 1 {
      guard let urlString = memberFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      return
    }
    if index == 0 {
      guard let urlString = memberFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      let urlStringNext = memberFeed[1].videoUrl
      nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
    } else if index == memberFeed.count - 1 {
      guard let urlString = memberFeed.last?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      let urlStringPrev = memberFeed[index - 1].videoUrl
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev ?? "")!)
    } else {
      let urlString = memberFeed[index].videoUrl
      currentPlayer = AVPlayer(url: URL(string: urlString ?? "")!)
      let urlStringPrev = memberFeed[index - 1].videoUrl
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev ?? "")!)
      let urlStringNext = memberFeed[index + 1].videoUrl
      nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
    }
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if memberFeed.count == 1 {
      memberFeed.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if memberFeed.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      memberFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: memberFeed[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == memberFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      memberFeed.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: memberFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      if memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      nextPlayer = AVPlayer(url: URL(string: memberFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      memberFeed.remove(at: currentVideoIndex)
      currentPlayer?.seek(to: .zero)
      if memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
    }
  }
}
