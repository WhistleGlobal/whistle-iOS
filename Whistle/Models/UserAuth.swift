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
    case imageUrl
    case userResponse
  }

  @AppStorage("isAccess") var isAccess = false
  @AppStorage("provider") var provider: Provider = .apple

  var email: String? = ""
  var userName = ""
  var imageUrl: String? = ""
  var userResponse = UserResponse(email: "")

  let keychain = KeychainSwift()

  var domainUrl: String {
    AppKeys.domainUrl as! String
  }

  var url: URL? {
    switch provider {
    case .apple:
//      return URL(string: "\(domainUrl)/user/profile?provider=Apple")
      return URL(string: "\(domainUrl)/user/profile")
    case .google:
//      return URL(string: "\(domainUrl)/user/profile?provider=Google")
      return URL(string: "\(domainUrl)/user/profile")
    }
  }

  func loadData(completion: @escaping () -> Void?) {
    guard let idTokenKey = keychain.get("id_token") else {
      log("id_Token nil")
      return
    }
    guard let url else {
      log("url nil")
      return
    }
    log("idToken \(idTokenKey)")
    let headers: HTTPHeaders = ["Authorization": "Bearer \(idTokenKey)"]
    AF.request(url, method: .get, headers: headers).responseDecodable(of: UserResponse.self) { response in
      switch response.result {
      case .success(let value):
        self.email = value.email
        self.userName = value.user_name ?? ""
        self.imageUrl = value.profile_img ?? ""
        self.isAccess = true
        completion()
      case .failure(let error):
        self.refresh()
        log(error)
      }
    }
  }

  func refresh() {
    guard let refreshTokenKey = keychain.get("refresh_token") else {
      log("refreshTokenKey nil")
      return
    }
    guard let url = URL(string: "https://madeuse.com/auth/apple/refresh") else {
      log("url nil")
      return
    }
    let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]

    let parameters: Parameters = ["refresh_token": refreshTokenKey]
    AF.request(url, method: .post, parameters: parameters, headers: headers).response { response in
      if let error = response.error {
        log("\(error.localizedDescription)")
        self.isAccess = false
        return
      }
      if let statusCode = response.response?.statusCode, statusCode == 401 {
        log("refresh_token expired or invalid")
      }
      guard let data = response.data else {
        log("data nil")
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
        log(error)
      }
    }
  }
}
