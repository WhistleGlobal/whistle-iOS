//
//  APIViewModel+ProfileProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import SwiftyJSON

extension APIViewModel: ProfileProtocol {
  func requestMyProfile() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/profile",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...500)
        .responseDecodable(of: Profile.self) { response in
          switch response.result {
          case .success(let success):
            self.myProfile = success
            log("success")
            continuation.resume()
          case .failure(let failure):
            log(failure)
            continuation.resume()
          }
        }
    }
  }

  func updateMyProfile() async -> ProfileEditIDView.InputValidationStatus {
    let params = [
      "user_name" : myProfile.userName,
      "introduce" : myProfile.introduce,
      "country" : "\(Locale.current.region?.identifier ?? "KR")",
    ]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/profile",
        method: .put,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200..<500)
        .response { response in
          switch response.result {
          case .success:
            if response.response?.statusCode == 403 {
              continuation.resume(returning: .updateFailed)
            } else if response.response?.statusCode == 200 {
              continuation.resume(returning: .valid)
            }
          case .failure(let error):
            log("Error: \(error)")
            continuation.resume(returning: .invalidID)
          }
        }
    }
  }

  func requestUserProfile(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/\(userId)/profile",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...300)
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
        "\(domainURL)/user/whistle/count",
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
        "\(domainURL)/user/\(userId)/whistle/count",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200..<300)
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

  func requestMyFollow() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/follow-list",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200...300)
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

  func requestUserFollow(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/\(userId)/follow-list",
        method: .get,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              self.userFollow = try self.decoder.decode(UserFollow.self, from: data ?? .init())
              log(self.userFollow.followerCount)
              log(self.userFollow.followerCount)
              log(self.userFollow.followerList)
              log(self.userFollow.followingList)
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

  func isAvailableUsername() async -> Bool {
    let params = ["user_name" : myProfile.userName]
    return await withUnsafeContinuation { continuation in
      AF.request(
        "\(domainURL)/user/check-username",
        method: .get,
        parameters: params,
        headers: contentTypeJson)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success:
            log("Success")
            continuation.resume(returning: true)
          case .failure:
            log("Failure")
            continuation.resume(returning: false)
          }
        }
    }
  }

  func deleteProfileImage() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/profile/image",
        method: .delete,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .responseData { response in
          switch response.result {
          case .success:
            log("success")
            continuation.resume()
          case .failure(let error):
            log("Request failed with error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func followUser(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(userId)/follow",
        method: .post,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .responseData { response in
          switch response.result {
          case .success:
            log("success")
            continuation.resume()
          case .failure(let error):
            log("Request failed with error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func unfollowUser(userId: Int) async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(userId)/follow",
        method: .delete,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .responseData { response in
          switch response.result {
          case .success:
            log("success")
            continuation.resume()
          case .failure(let error):
            log("Request failed with error: \(error)")
            continuation.resume()
          }
        }
    }
  }

  func requestUserCreateDate() {
    AF.request(
      "\(domainURL)/user/created-at",
      method: .get,
      headers: contentTypeXwwwForm)
      .validate(statusCode: 200...300)
      .responseData { response in
        switch response.result {
        case .success(let data):
          let json = JSON(data)
          let dateString = json["created_at"]
          log(dateString.type)
          log(dateString.string)
          let inputDateString = dateString.string
          let inputDateFormatter = DateFormatter()
          inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
          if let date = inputDateFormatter.date(from: inputDateString ?? "") {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "yyyy.MM.dd"
            let formattedDateString = outputDateFormatter.string(from: date)
            log(formattedDateString)
            self.userCreatedDate = formattedDateString
          } else {
            log("Failed to parse the date string")
          }
          log("success")
        case .failure(let error):
          log(error)
        }
      }
  }

  func rebokeAppleToken() async {
    let params = [
      "refresh_token" : "\(keychain.get("refresh_token") ?? "")",
    ]
    log("\(keychain.get("refresh_token") ?? "")")
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainUrl)/apple/logout",
        method: .post,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success(let data):
            log(data)
            continuation.resume()
          case .failure(let error):
            log(error)
            continuation.resume()
          }
        }
    }
  }
}
