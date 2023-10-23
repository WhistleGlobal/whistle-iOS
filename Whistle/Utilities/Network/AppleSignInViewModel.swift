//
//  AppleSignInViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import Alamofire
import AuthenticationServices
import Foundation
import KeychainSwift
import SwiftUI

class AppleSignInViewModel: ObservableObject {
  @StateObject var userAuth = UserAuth.shared
  @Published var gotoTab = false
  @AppStorage("isAccess") var isAccess = false
  @AppStorage("provider") var provider: Provider = .apple
  let keychain = KeychainSwift()

  var domainURL: String {
    AppKeys.domainURL as! String
  }

  // 밑으로는 사용 되는 함수들
  func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
    request.requestedScopes = [.email]
  }

  func handleResult(_ result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
      guard
        let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
        let authCodeData = credential.authorizationCode,
        let authCodeString = String(data: authCodeData, encoding: .utf8)
      else { return }
      sendAuthCodeToBackend(authCode: authCodeString)
    case .failure(let error):
      log("[auth fail] Error : \(error)")
    }
  }

  // 백엔드 서버에 인증 코드를 전송하는 함수
  func sendAuthCodeToBackend(authCode: String) {
    let url = "\(domainURL)/auth/apple"
    let parameters: [String: Any] = [
      "authCode": authCode,
    ]
    // Alamofire 사용하여 POST 요청
    AF.request(
      url,
      method: .post,
      parameters: parameters,
      encoding: URLEncoding.default,
      headers: ["Content-Type": "application/x-www-form-urlencoded"])
      .responseJSON { response in
        switch response.result {
        case .success(let value):
          // JSON 데이터 파싱
          if
            let jsonObject = value as? [String: Any],
            let id_token = jsonObject["id_token"] as? String,
            let refresh_token = jsonObject["refresh_token"] as? String
          {
            log(id_token)
            log(refresh_token)
            DispatchQueue.main.async {
              self.keychain.set("\(id_token)", forKey: "id_token")
              self.keychain.set("\(refresh_token)", forKey: "refresh_token")
              self.provider = .apple
              self.userAuth.loadData {
                self.gotoTab = true
              }
            }
          }
        case .failure(let error):
          log("Error sending authCode to backend: \(error.localizedDescription)")
        }
      }
  }
}
