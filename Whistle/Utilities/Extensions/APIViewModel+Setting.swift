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

// MARK: - APIViewModel + SettingProtocol

extension APIViewModel: SettingProtocol {
  func requestNotiSetting() async {
    await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/notification/setting",
        method: .get,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 500)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              guard let data else {
                return
              }
              let json = try JSON(data: data)
              let decoder = JSONDecoder()
              self.notiSetting = try decoder.decode(NotiSetting.self, from: data)
              continuation.resume()
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

  // FIXME: - 코드 리팩토링이 필요함 (URL 뻬고 모든 코드가 중복)

  func updateSettingWhistle(newSetting: Bool) async {
    let params = ["newSetting": newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/notification/setting/whistle",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let data else {
              return
            }
            continuation.resume()
          case .failure(let error):
            log("\(error)")
            continuation.resume()
          }
        }
    }
  }

  func updateSettingFollow(newSetting: Bool) async {
    let params = ["newSetting": newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/notification/setting/follow",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm).validate(statusCode: 200 ... 300).response { response in
        switch response.result {
        case .success(let data):
          guard let data else {
            return
          }
          continuation.resume()
        case .failure(let error):
          log("\(error)")
          continuation.resume()
        }
      }
    }
  }

  func updateSettingInfo(newSetting: Bool) async {
    let params = ["newSetting": newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/notification/setting/info",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let data else {
              return
            }
            continuation.resume()
          case .failure(let error):
            log("\(error)")
            continuation.resume()
          }
        }
    }
  }

  func updateSettingAd(newSetting: Bool) async {
    let params = ["newSetting": newSetting ? 1 : 0]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/user/notification/setting/ad",
        method: .patch,
        parameters: params,
        headers: contentTypeXwwwForm)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            guard let data else {
              return
            }
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
      "device_token": "\(deviceToken)",
      "system_name": "\(UIDevice.current.systemName)",
      "system_version": "\(UIDevice.current.systemVersion)",
      "device_model": "\(UIDevice.current.name)",
    ]

    AF.request(
      "\(domainURL)/system/device-token",
      method: .post,
      parameters: params,
      headers: contentTypeXwwwForm)
      .validate(statusCode: 200 ... 300)
      .response { response in
        switch response.result {
        case .success(let data):
          guard let data else {
            return
          }
          completion()
        case .failure(let error):
          log("\(error)")
        }
      }
  }

  func requestVersionCheck() async {
    let params = ["appVersion": "\(Bundle.main.appVersion ?? "Unknown")"]
    return await withCheckedContinuation { continuation in
      AF.request(
        "\(domainURL)/system/versionCheck",
        method: .get,
        parameters: params,
        headers: contentTypeJson)
        .validate(statusCode: 200 ... 300)
        .response { response in
          switch response.result {
          case .success(let data):
            do {
              // tempContent.contentId = jsonObject["content_id"] as? Int
              guard let data else { return }
              let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
              self.versionCheck.needUpdate = json?["needUpdate"] as? Bool ?? false
              self.versionCheck.reason = json?["reason"] as? String ?? ""
              self.versionCheck.forceUpdate = json?["forceUpdate"] as? Bool ?? false
              self.versionCheck
                .latestAppVersion = json?["latestAppVersion"] as? String ?? "\(Bundle.main.appVersion ?? "Unknown")"
            } catch {
              log(error)
            }
            continuation.resume()
          case .failure(let error):
            log(error)
            continuation.resume()
          }
        }
    }
  }

  func checkUpdateAvailable() async -> Bool {
    guard
      let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
      let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
      let url = URL(string: "http://itunes.apple.com/lookup?bundleId=" + bundleID),
      let data = try? Data(contentsOf: url),
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
      let results = jsonData["results"] as? [[String: Any]],
      results.count > 0,
      let appStoreVersion = results[0]["version"] as? String
    else {
      return false
    }
    let currentVersionArray = currentVersion.split(separator: ".").map { $0 }
    let appStoreVersionArray = appStoreVersion.split(separator: ".").map { $0 }
    if currentVersionArray[0] < appStoreVersionArray[0] {
      return true
    } else {
      return currentVersionArray[1] < appStoreVersionArray[1] ? true : false
    }
  }
}

extension Bundle {
  var appVersion: String? {
    infoDictionary?["CFBundleShortVersionString"] as? String
  }
}
