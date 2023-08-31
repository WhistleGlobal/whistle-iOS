//
//  AppleSignInViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import Alamofire
import AuthenticationServices
import Foundation
import SwiftUI

class AppleSignInViewModel: ObservableObject {
  @Published var userAuth = UserAuth()
  @Published var gotoTab = false
  @AppStorage("idToken") var idToken: String?
  @AppStorage("refreshToken") var refreshToken: String?
  @AppStorage("isAccess") var isAccess = false
  @AppStorage("provider") var provider: Provider = .apple

  // 밑으로는 사용 되는 함수들
  func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
    log("")
    request.requestedScopes = [.email]
  }

  func handleResult(_ result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
      log("auth success")
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
    print("백엔드 서버로 인증 코드 전송 시작: \(authCode)")

    let url = "https://readywhistle.com/auth/apple"
    let parameters: [String: String] = [
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
            // 메인 스레드에서 UI 업데이트
            DispatchQueue.main.async {
              self.idToken = id_token
              self.refreshToken = refresh_token
              self.provider = .apple
              // 데이터를 다시 로드
              self.userAuth.loadData {
                self.gotoTab = true
              }
            }
          }
        case .failure(let error):
          // 오류 처리
          print("Error sending authCode to backend: \(error.localizedDescription)")
        }
      }
  }
}
