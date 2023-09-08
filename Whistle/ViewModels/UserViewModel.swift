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

  var domainUrl: String {
    AppKeys.domainUrl as! String
  }
}

// MARK: - 데이터 처리
extension UserViewModel {

  func requestMyProfile() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/profile",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .responseDecodable(of: Profile.self) { response in
          switch response.result {
          case .success(let success):
            self.myProfile = success
            continuation.resume()
          case .failure(let failure):
            log(failure)
            continuation.resume()
          }
        }
    }
  }

  func updateMyProfile() async {
    let params = [
      "user_name" : myProfile.userName,
      "introduce" : myProfile.introduce,
      "country" : "Korea(Korea)",
    ]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/profile",
        method: .put,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...500)
        .response { response in
          switch response.result {
          case .success(let data):
            if let responseData = data {
              log("Success: \(responseData)")
            } else {
              log("Success with no data")
            }
            continuation.resume()
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func requestUserProfile(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/\(userId)/profile",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .responseDecodable(of: UserProfile.self) { response in
          switch response.result {
          case .success(let success):
            self.userProfile = success
            continuation.resume()
          case .failure(let failure):
            log(failure)
            continuation.resume()
          }
        }
    }
  }

  func requestMyWhistlesCount() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/whistle/count",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200..<300) // Validate success status codes
        .response { response in
          switch response.result {
          case .success(let data):
            guard let responseData = data else {
              return
            }
            do {
              if
                let jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]],
                let firstObject = jsonArray.first,
                let count = firstObject["whistle_all_count"] as? Int
              {
                self.myWhistleCount = count
                log("/whistle/count response \(count)")
                continuation.resume()
              } else {
                log("Invalid JSON format or missing 'whistle_all_count' key")
                continuation.resume()
              }
            } catch {
              log("Error parsing JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume()
          }
        }
    }
  }


  func requestUserWhistlesCount(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/\(userId)/whistle/count",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200..<300) // Validate success status codes
        .response { response in
          switch response.result {
          case .success(let data):
            guard let responseData = data else {
              return
            }
            do {
              if
                let jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]],
                let firstObject = jsonArray.first,
                let count = firstObject["whistle_all_count"] as? Int
              {
                self.userWhistleCount = count
                log("/whistle/count response \(count)")
                continuation.resume()
              } else {
                log("Invalid JSON format or missing 'whistle_all_count' key")
              }
            } catch {
              log("Error parsing JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            log("Error: \(error)")
          }
        }
    }
  }

  // FIXME: - Following Follower가 더미데이터상 없어서 Following Follower 데이터가 있을때 다시 한번 테스트 할 것
  func requestMyFollow() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/follow-list",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .responseData { response in
          switch response.result {
          case .success(let data):
            do {
              self.myFollow = try self.decoder.decode(Follow.self, from: data)
              continuation.resume()
            } catch {
              log("Error decoding JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            log("Request failed with error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  // FIXME: - Following Follower가 더미데이터상 없어서 Following Follower 데이터가 있을때 다시 한번 테스트 할 것
  func requestUserFollow(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/\(userId)/follow-list",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .responseData { response in
          switch response.result {
          case .success(let data):
            do {
              self.userFollow = try self.decoder.decode(Follow.self, from: data)
              continuation.resume()
            } catch {
              log("Error decoding JSON: \(error)")
              continuation.resume()
            }
          case .failure(let error):
            log("Request failed with error: \(error)")
            continuation.resume()
          }
        }
    }
  }

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

  // FIXME: - 더미 데이터를 넣어서 테스트할 것
  func requestNotiSetting() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/notification/setting",
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
              self.notiSetting = try decoder.decode(NotiSetting.self, from: data)
              continuation.resume()
            } catch {
              log("Error parsing JSON: \(error)")
              log("NotiSetting을 불러올 수 없습니다.")
              continuation.resume()
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  // FIXME: - 코드 리팩토링이 필요함 (URL 뻬고 모든 코드가 중복)

  func updateSettingWhistle(newSetting: Bool) async {
    let params = ["newSetting" : newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/notification/setting/whistle",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let data else {
              return
            }
            log("Success: \(data)")
            continuation.resume()
          case .failure(let error):
            log("\(error)")
            continuation.resume()
          }
        }
    }
  }


  func updateSettingFollow(newSetting: Bool) async {
    let params = ["newSetting" : newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/notification/setting/follow",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm).validate(statusCode: 200...300).response { response in
        switch response.result {
        case .success(let data):
          guard let data else {
            return
          }
          log("Success: \(data)")
          continuation.resume()
        case .failure(let error):
          log("\(error)")
          continuation.resume()
        }
      }
    }
  }

  func updateSettingInfo(newSetting: Bool) async {
    let params = ["newSetting" : newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/notification/setting/info",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let data else {
              return
            }
            log("Success: \(data)")
            continuation.resume()
          case .failure(let error):
            log("\(error)")
            continuation.resume()
          }
        }
    }
  }

  func updateSettingAd(newSetting: Bool) async {
    let params = ["newSetting" : newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/user/notification/setting/ad",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let data else {
              return
            }
            log("Success: \(data)")
            continuation.resume()
          case .failure(let error):
            log("\(error)")
            continuation.resume()
          }
        }
    }
  }

  func uploadPhoto(image: UIImage, completion: @escaping (String) -> Void) async {
    guard let image = image.jpegData(compressionQuality: 0.5) else {
      return
    }
    return await withCheckedContinuation { continuation in
      AF.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      }, to: "\(domainUrl)/user/profile/image", headers: contentTypeMultipart)
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
