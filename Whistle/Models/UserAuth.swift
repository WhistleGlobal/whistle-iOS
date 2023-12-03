//
//  UserAuth.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

// import GoogleSignIn
// import GoogleSignInSwift
import Alamofire
import KeychainSwift
import Mixpanel
import SwiftUI

// MARK: - Provider

enum Provider: String {
  case apple
  case google
}

// MARK: - UserAuth

class UserAuth: ObservableObject {
  enum CodingKeys: String, CodingKey {
    case idToken
    case refreshToken
    case isAccess
    case provider
    case email
    case userName
    case imageURL
    case userResponse
  }

  static let shared = UserAuth()
  private init() { }

  @AppStorage("isAccess") var isAccess = false
  @AppStorage("provider") var provider: Provider = .apple
  @AppStorage("deviceToken") var deviceToken: String?
  @AppStorage("isMyTeamSelected") var isMyTeamSelected = false

  var apiViewModel = APIViewModel.shared
  var email: String? = ""
  var userName = ""
  var imageURL: String? = ""
  var userResponse = UserResponse(email: "")

  let keychain = KeychainSwift()

  var domainURL: String {
    AppKeys.domainURL as! String
  }

  var url: URL? {
    switch provider {
    case .apple:
//      return URL(string: "\(domainUrl)/user/profile?provider=Apple")
      URL(string: "\(domainURL)/user/profile")
    case .google:
//      return URL(string: "\(domainUrl)/user/profile?provider=Google")
      URL(string: "\(domainURL)/user/profile")
    }
  }

  func loadData(completion: @escaping () -> Void?) {
    guard let idTokenKey = keychain.get("id_token") else {
      return
    }
    guard let url else {
      return
    }
    WhistleLogger.logger.debug("idToken \(idTokenKey)")
    let headers: HTTPHeaders = ["Authorization": "Bearer \(idTokenKey)"]
    AF.request(url, method: .get, headers: headers)
      .validate(statusCode: 200 ... 300)
      .responseDecodable(of: MyProfile.self) { response in
        switch response.result {
        case .success(let data):
          guard let deviceToken = self.deviceToken else {
            return
          }
          self.apiViewModel.uploadDeviceToken(deviceToken: deviceToken) { }
          if GuestUploadModel.shared.isNotAccessRecord {
            if !GuestUploadModel.shared.isMusicEdit {
              GuestUploadModel.shared.goDescriptionTagView = true
            }
            GuestUploadModel.shared.istempAccess = true
          } else {
            self.isAccess = true
            APIViewModel.shared.myProfile = data
            if APIViewModel.shared.myProfile.myTeam != nil {
              self.isMyTeamSelected = true
            } else {
              self.isMyTeamSelected = false
            }
          }

          Mixpanel.mainInstance().identify(distinctId: String(self.apiViewModel.myProfile.userId))
          Task {
            await self.apiViewModel.requestMyFollow()
            await self.apiViewModel.requestMyWhistlesCount()
            await self.apiViewModel.requestMyFollow()
            Mixpanel.mainInstance().people.set(
              property: "number_of_whisitle",
              to: "\(self.apiViewModel.myWhistleCount)")
            Mixpanel.mainInstance().people.set(
              property: "number_of_whisitle",
              to: "\(self.apiViewModel.myWhistleCount)")
            Mixpanel.mainInstance().people.set(
              property: "$number_of_following",
              to: "\(self.apiViewModel.myFollow.followingCount)")
            Mixpanel.mainInstance().people.set(
              property: "$number_of_follower",
              to: "\(self.apiViewModel.myFollow.followerCount)")
          }

          Mixpanel.mainInstance().people.set(property: "$name", to: String(self.apiViewModel.myProfile.userId))
          Mixpanel.mainInstance().people.set(property: "$email", to: self.apiViewModel.myProfile.email)
          Mixpanel.mainInstance().people.set(property: "$first_login_date", to: Date.now.koreaTimezone())
          Mixpanel.mainInstance().people.set(property: "$login_method", to: "\(self.provider.rawValue)")
          Mixpanel.mainInstance().track(event: "login", properties: [
            "did_login": true,
          ])

          completion()
        case .failure(let error):
          switch self.provider {
          case .apple:
            WhistleLogger.logger.error("Error: \(error)")
            self.refresh()
          case .google:
            WhistleLogger.logger.error("Error: \(error)")
          }
        }
      }
  }

  func refresh() {
    guard let refreshTokenKey = keychain.get("refresh_token") else {
      return
    }
    guard let url = URL(string: "\(domainURL)/auth/apple/refresh") else {
      return
    }
    let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]

    let parameters: Parameters = ["refresh_token": refreshTokenKey]
    AF.request(url, method: .post, parameters: parameters, headers: headers).response { response in
      if let error = response.error {
        WhistleLogger.logger.error("Error: \(error)")
        self.isAccess = false
        return
      }
      if let statusCode = response.response?.statusCode, statusCode == 401 { }
      guard let data = response.data else {
        return
      }
      do {
        if
          let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
          let idToken = jsonObject["id_token"] as? String
        {
          self.keychain.set(idToken, forKey: "id_token")
          self.loadData { }
        }
      } catch {
        WhistleLogger.logger.error("Error: \(error)")
      }
    }
  }

  func appleSignout() {
    keychain.set("", forKey: "id_token")
    isAccess = false
  }
}
