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
  @Published var myProfile = MyProfile()
  @Published var myWhistleCount = 0
  @Published var myFollow = MyFollow()
  @Published var myFeed: [MyContent] = []
  @Published var bookmark: [Bookmark] = []
  @Published var notiSetting: NotiSetting = .init()
  @Published var mainFeed: [MainContent] = []
  @Published var guestFeed: [GuestContent] = []
  @Published var reportedContent: [ReportedContent] = []
  @Published var userCreatedDate = ""
  @Published var versionCheck = VersionCheck()
  @Published var notiList: [NotificationModel] = []
  @Published var singleContent = MainContent()
  @Published var searchedUser: [SearchedUser] = []
  @Published var searchedTag: [SearchedTag] = []
  @Published var searchedContent: [MainContent] = []
  @Published var tagSearchedRecentContent: [MainContent] = []
  @Published var tagSearchedRecentContentPopular: [MainContent] = []
  @Published var myTeamFeed: [MainContent] = []
  @Published var rankingModel = RankingModel()

  let decoder = JSONDecoder()

  func reset() {
    myProfile = .init()
    myWhistleCount = 0
    myFollow = MyFollow()
    myFeed = []
    bookmark = []
    notiSetting = .init()
    mainFeed = []
    guestFeed = []
    reportedContent = []
    userCreatedDate = ""
    notiList = []
    singleContent = MainContent()
    searchedUser = []
    searchedTag = []
    searchedContent = []
    myTeamFeed = []
    rankingModel = RankingModel()
    tagSearchedRecentContent = []
    tagSearchedRecentContentPopular = []
  }
}

// MARK: - Computed Property

extension APIViewModel {
  var idToken: String {
    guard let idTokenKey = keychain.get("id_token") else {
      WhistleLogger.logger.debug("id_token nil")
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
