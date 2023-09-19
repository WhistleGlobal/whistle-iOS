//
//  APIViewModel+Setting.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

extension APIViewModel: SettingProtocol {
  func requestNotiSetting() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/notification/setting",
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
        "\(domainURL)/user/notification/setting/whistle",
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
        "\(domainURL)/user/notification/setting/follow",
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
        "\(domainURL)/user/notification/setting/info",
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
        "\(domainURL)/user/notification/setting/ad",
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

  func uploadDeviceToken(deviceToken: String, completion: @escaping () -> Void) {
    let params = [
      "device_token" : "\(deviceToken)",
      "system_name" : "\(UIDevice.current.systemName)",
      "system_version" : "\(UIDevice.current.systemVersion)",
      "device_model" : "\(UIDevice.current.name)",
    ]

    AF.request(
      "\(domainURL)/auth/device-token",
      method: .post,
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
          completion()
        case .failure(let error):
          log("\(error)")
        }
      }
  }
}
