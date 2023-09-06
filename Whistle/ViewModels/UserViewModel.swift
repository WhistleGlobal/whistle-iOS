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
import UIKit

// MARK: - UserViewModel

class UserViewModel: ObservableObject {
  let keychain = KeychainSwift()
  @Published var myProfile = Profile()
  @Published var userProfile = UserProfile()
  @Published var myWhistleCount = 0
  @Published var userWhistleCount = 0
  @Published var myFollow = Follow()
  @Published var userFollow = Follow()
  @Published var myPostFeed: [PostFeed] = []
  @Published var userPostFeed: [UserPostFeed] = []
  @Published var bookmark: [Bookmark] = []
  @Published var notiSetting: NotiSetting = .init()
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
extension UserViewModel {

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
      .responseDecodable(of: Profile.self) { response in
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
      "user_name" : myProfile.userName,
      "introduce" : myProfile.introduce,
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

  // FIXME: - 더미 데이터를 넣어서 테스트할 것
  func requestMyBookmark() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/post/bookmark",
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
            log("\(json)")
            let decoder = JSONDecoder()
            self.bookmark = try decoder.decode([Bookmark].self, from: data)
          } catch {
            log("Error parsing JSON: \(error)")
            log("북마크를 불러올 수 없습니다.")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }

  // FIXME: - 더미 데이터를 넣어서 테스트할 것
  func requestNotiSetting() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "application/json",
    ]
    AF.request(
      "\(domainUrl)/user/notification/setting",
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
            log("\(json)")
            let decoder = JSONDecoder()
            self.notiSetting = try decoder.decode(NotiSetting.self, from: data)
          } catch {
            log("Error parsing JSON: \(error)")
            log("NotiSetting을 불러올 수 없습니다.")
          }
        case .failure(let error):
          log("Error: \(error)")
        }
      }
  }


  func uploadPhoto(image: UIImage, completion: @escaping (String) -> Void) {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(idToken)",
      "Content-Type": "multipart/form-data",
    ]
    let uploadURL = "\(domainUrl)/user/profile/image"
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
      return
    }
    // id_token을 올바르게 얻어와서 변환
    guard let idTokenData = "Bearer \(idToken)".data(using: .utf8) else {
      return
    }
    log(idTokenData)
    AF.upload(multipartFormData: { multipartFormData in
      multipartFormData.append(imageData, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
      multipartFormData.append(idTokenData, withName: "id_token")
    }, to: uploadURL, method: .post,headers: headers)
      .responseString { response in
        switch response.result {
        case .success(let url):
          log(url)
          completion(url)
        case .failure(let error):
          log(error)
        }
      }
  }

}
