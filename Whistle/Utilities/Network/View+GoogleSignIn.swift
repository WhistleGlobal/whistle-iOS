//
//  View+GoogleSignIn.swift
//  Whistle
//
//  Created by ChoiYujin on 10/23/23.
//

import Foundation
import GoogleSignIn
import KeychainSwift
import SwiftUI

// MARK: - View + GoogleSignIn

extension View {
  var domainURL: String {
    AppKeys.domainURL as! String
  }

  func handleSignInButton() {
    let keychain = KeychainSwift()
    guard
      let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?
        .rootViewController
    else {
      return
    }

    GIDSignIn.sharedInstance.signIn(
      withPresenting: rootViewController)
    { signInResult, error in

      guard let result = signInResult else { return }

      result.user.refreshTokensIfNeeded { user, error in
        guard error == nil else { return }
        guard let user else { return }

        let idToken = user.idToken

        keychain.set("", forKey: "refresh_token")

        if let idTokenString = idToken?.tokenString {
          print("저장될 ID 토큰: \(idTokenString)")
          keychain.set(idTokenString, forKey: "id_token")
        }

        UserAuth.shared.provider = .google
        tokenSignIn(idToken: keychain.get("id_token") ?? "")
      }
    }
  }

  func tokenSignIn(idToken: String) {
    guard let authData = try? JSONEncoder().encode(["idToken": idToken]) else {
      return
    }

    guard let url = URL(string: "\(domainURL)/auth/google") else {
      print("URL is nil")
      return
    }
    log("\(idToken)")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 서버 통신
    let task = URLSession.shared.uploadTask(with: request, from: authData) { _, _, error in
      if let error {
        print("서버 통신 에러: \(error)")
      }
      DispatchQueue.main.async {
        UserAuth.shared.loadData { }
      }
    }
    task.resume()
  }
}
