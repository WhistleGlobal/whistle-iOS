//
//  APIViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift
import SwiftyJSON
import UIKit

// MARK: - APIViewModel

class APIViewModel: ObservableObject {

  static let shared = APIViewModel()
  private init() { }

  let keychain = KeychainSwift()
  let publisher: PassthroughSubject<UUID, Never> = PassthroughSubject()
  @Published var myProfile = Profile()
  @Published var userProfile = UserProfile()
  @Published var myWhistleCount = 0
  @Published var userWhistleCount = 0
  @Published var myFollow = Follow()
  @Published var userFollow = UserFollow()
  @Published var myPostFeed: [PostFeed] = []
  @Published var userPostFeed: [UserPostFeed] = []
  @Published var bookmark: [Bookmark] = []
  @Published var notiSetting: NotiSetting = .init()
  @Published var contentList: [MainContent] = []
  @Published var noSignInContentList: [NoSignInMainContent] = []
  @Published var reportedContent: [ReportedContent] = []
  @Published var userCreatedDate = ""
  @Published var versionCheck = VersionCheck()

  let decoder = JSONDecoder()

  func reset() {
    myProfile = .init()
    userProfile = .init()
    myWhistleCount = 0
    userWhistleCount = 0
    myFollow = Follow()
    userFollow = UserFollow()
    myPostFeed = []
    userPostFeed = []
    bookmark = []
    notiSetting = .init()
    contentList = []
    noSignInContentList = []
    reportedContent = []
    userCreatedDate = ""
  }
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

  var domainURL: String {
    AppKeys.domainURL as! String
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
