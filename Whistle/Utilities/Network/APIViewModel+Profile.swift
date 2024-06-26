//
//  APIViewModel+MyProfile.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import Mixpanel
import SwiftyJSON

extension APIViewModel: ProfileProtocol {

  func requestMyProfile() async {
    WhistleLogger.logger.debug("requestMyProfile()")
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/profile",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 500)
        .responseDecodable(of: MyProfile.self) { response in
          switch response.result {
          case .success(let success):
            self.myProfile = success
            continuation.resume()
          case .failure:
            continuation.resume()
          }
        }
    }
  }

  func updateMyProfile() async -> ProfileEditIDView.InputValidationStatus {
    let params = [
      "user_name": myProfile.userName,
      "introduce": myProfile.introduce,
      "country": "\(Locale.current.region?.identifier ?? "KR")",
    ]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/profile",
        method: .put,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ..< 500)
        .response { response in
          switch response.result {
          case .success:
            if response.response?.statusCode == 403 {
              continuation.resume(returning: .updateFailed)
            } else if response.response?.statusCode == 200 {
              continuation.resume(returning: .valid)
            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume(returning: .invalidID)
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
        .validate(statusCode: 200 ..< 300) // Validate success status codes
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
                continuation.resume()
              } else {
                continuation.resume()
              }
            } catch {
              continuation.resume()
            }
          case .failure(let error):
            WhistleLogger.logger.error("Failure: \(error)")
            continuation.resume()
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
        .validate(statusCode: 200 ... 300)
        .responseData { response in
          switch response.result {
          case .success(let data):
            do {
              self.myFollow = try self.decoder.decode(MyFollow.self, from: data)
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

  func isAvailableUsername() async -> Bool {
    let params = ["user_name": myProfile.userName]
    return await withUnsafeContinuation { continuation in
      AF.request(
        "\(domainURL)/user/check-username",
        method: .get,
        parameters: params,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success:
            continuation.resume(returning: true)
          case .failure:
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
        .validate(statusCode: 200 ... 300)
        .responseData { response in
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

  func followAction(userID: Int, method: Alamofire.HTTPMethod) async {
    if userID == 0 {
      return
    }
    if method == .post {
      Mixpanel.mainInstance().track(event: "follow")
    }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(userID)/follow",
        method: method,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .responseData { response in
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

  func requestUserCreateDate() {
    AF.request(
      "\(domainURL)/user/signup-date",
      method: .get,
      headers: contentTypeXwwwForm)
      .validate(statusCode: 200 ... 300)
      .responseData { response in
        switch response.result {
        case .success(let data):
          let json = JSON(data)
          let dateString = json["signup_date"]
          let inputDateString = dateString.string
          let inputDateFormatter = DateFormatter()
          inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
          if let date = inputDateFormatter.date(from: inputDateString ?? "") {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "yyyy.MM.dd"
            let formattedDateString = outputDateFormatter.string(from: date)
            self.userCreatedDate = formattedDateString
          }
        case .failure(let error):
          WhistleLogger.logger.error("Failure: \(error)")
        }
      }
  }

  func rebokeAppleToken() async {
    let params = [
      "refresh_token": "\(keychain.get("refresh_token") ?? "")",
    ]

    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/apple/logout",
        method: .post,
        parameters: params,
        headers: contentTypeXwwwForm)
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

  func blockAction(userID: Int, method: Alamofire.HTTPMethod) async {
    if userID == 0 {
      return
    }
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/action/\(userID)/block",
        method: method,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .responseData { response in
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

  func updateMyTeam(myTeam: String) async {
    let params = [
      "myteam": myTeam,
    ]
    return await withCheckedContinuation { continuaion in
      AF.request(
        "\(domainURL)/user/myteam",
        method: .put,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200...300)
        .response { response in
          switch response.result {
          case .success:
            WhistleLogger.logger.debug("updateMyTeam success!!")
            continuaion.resume()
          case .failure(let error):
            WhistleLogger.logger.error("updateMyTeam: \(error)")
            continuaion.resume()
          }
        }
    }
  }

  func requestRankingList(userID: Int) {
    AF.request(
      "\(domainURL)/user/whistle-ranking/\(userID)",
      method: .get,
      headers: contentTypeJson)
      .validate(statusCode: 200..<300)
      .responseDecodable(of: RankingModel.self) { response in
        switch response.result {
        case .success(let data):
          self.rankingModel = data
        case .failure(let error):
          WhistleLogger.logger.error("requestRankingList Error: \(error)")
        }
      }
  }
}
