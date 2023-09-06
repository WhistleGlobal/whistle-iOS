//
//  ProfileViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Alamofire
import Foundation
import KeychainSwift
import SwiftyJSON

// MARK: - ProfileViewModel

class ProfileViewModel: ObservableObject {
  let keychain = KeychainSwift()
  @Published var myProfile = MyProfile()
  @Published var userProfile = UserProfile()
  @Published var myWhistleCount = 0
  @Published var userWhistleCount = 0
  @Published var myFollow = Follow()
  @Published var userFollow = Follow()
  @Published var myPostFeed: [PostFeed] = []
  @Published var userPostFeed: [UserPostFeed] = []
  let decoder = JSONDecoder()

  var idToken: String {
    guard let idTokenKey = keychain.get("id_token") else {
      log("id_Token nil")
      return ""
    }
    return idTokenKey
  }

  var domainUrl: String {
    AppKeys.domainUrl as! String
  }
}

// MARK: - 데이터 처리
extension ProfileViewModel {

  func requestMyProfile() async {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/profile",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .responseDecodable(of: MyProfile.self) { response in
        switch response.result {
        case .success(let success):
          self.myProfile = success
        case .failure(let failure):
          log(failure)
        }
      }
  }

  func updateMyProfile() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/x-www-form-urlencoded",
    ]
    let params = [
      "user_name" : "최유진(Eugene)",
      "introduce" : "나는 최유진(Eugene)",
      "country" : "Korea(Korea)",
    ]
    AF.request(
      "\(domainUrl)/user/profile",
      method: .put,
      parameters: params,
      headers: headers)
      .validate(statusCode: 200...500)
      .response { response in
        switch response.result {
        case .success(let data):
          if let responseData = data {
            log("Success: \(responseData)")
          } else {
            log("Success with no data")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }

  func requestUserProfile(userId: Int) async {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/\(userId)/profile",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .responseDecodable(of: UserProfile.self) { response in
        switch response.result {
        case .success(let success):
          self.userProfile = success
        case .failure(let failure):
          log(failure)
        }
      }
  }

  func requestMyWhistlesCount() async {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/whistle/count",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .response { response in
        switch response.result {
        case .success(let data):
          do {
            guard let data else {
              return
            }
            let json = try JSON(data: data)
            let count = json["whistle_all_count"].intValue
            log("/whistle/count response \(count)")
            self.myWhistleCount = count
          } catch {
            log("Error parsing JSON: \(error)")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }

  func requestUserWhistlesCount(userId: Int) async {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/\(userId)/whistle/count",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .response { response in
        switch response.result {
        case .success(let data):
          do {
            guard let data else {
              return
            }
            let json = try JSON(data: data)
            let count = json["whistle_all_count"].intValue
            log("/whistle/count response \(count)")
            self.userWhistleCount = count
          } catch {
            log("Error parsing JSON: \(error)")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }

  // FIXME: - Following Follower가 더미데이터상 없어서 Following Follower 데이터가 있을때 다시 한번 테스트 할 것
  func requestMyFollow() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/follow-list",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .responseData { response in
        switch response.result {
        case .success(let data):
          do {
            self.myFollow = try self.decoder.decode(Follow.self, from: data)
            for myFollower in self.myFollow.followers {
              log(myFollower.userId)
            }
            log(self.myFollow.followerCount)
            for myFollowing in self.myFollow.following {
              log(myFollowing.userId)
            }
            log(self.myFollow.followingCount)
          } catch {
            log("Error decoding JSON: \(error)")
          }
        case .failure(let error):
          log("Request failed with error: \(error)")
        }
      }
  }

  // FIXME: - Following Follower가 더미데이터상 없어서 Following Follower 데이터가 있을때 다시 한번 테스트 할 것
  func requestUserFollow(userId: Int) {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/\(userId)/follow-list",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .responseData { response in
        switch response.result {
        case .success(let data):
          do {
            self.userFollow = try self.decoder.decode(Follow.self, from: data)
            for follower in self.userFollow.followers {
              log(follower.userId)
            }
            log(self.userFollow.followerCount)
            for following in self.userFollow.following {
              log(following.userId)
            }
            log(self.userFollow.followingCount)
          } catch {
            log("Error decoding JSON: \(error)")
          }
        case .failure(let error):
          log("Request failed with error: \(error)")
        }
      }
  }

    // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestMyPostFeed() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/post/feed",
      method: .get,
      headers: headers)
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
          } catch {
            log("Error parsing JSON: \(error)")
            log("피드를 불러올 수 없습니다.")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }
    // FIXME: - 데이터가 없을 시 처리할 로직 생각할 것
  func requestUserPostFeed(userId: Int) {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/\(userId)/post/feed",
      method: .get,
      headers: headers)
      .validate(statusCode: 200...500)
      .response { response in
        switch response.result {
        case .success(let data):
          do {
            guard let data else {
              return
            }
            self.userPostFeed = try self.decoder.decode([UserPostFeed].self, from: data)
          } catch {
            log("Error parsing JSON: \(error)")
            log("피드를 불러올 수 없습니다.")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }
}
