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

// MARK: - APIViewModel

class APIViewModel: ObservableObject {
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
}

// MARK: - Computed Property

extension APIViewModel {

  var idToken: String {
    guard let idTokenKey = keychain.get("id_token") else {
      log("id_Token nil")
      return ""
    }
    return idTokenKey
  }

  var domainUrl: String {
    AppKeys.domainUrl as! String
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
}
