//
//  PostFeedProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire
import Foundation
import UIKit

protocol PostFeedProtocol {
  func requestMyPostFeed() async
  func requestMemberPostFeed(userID: Int) async
  func requestMyBookmark() async
  func requestMainFeed(completion: @escaping (DataResponse<[MainContent], AFError>) -> Void)
  func requestReportedFeed() async
  // TODO: - MainView 정리 시 함께 정리
  func publisherSend()
  func bookmarkAction(contentID: Int, method: HTTPMethod) async -> Bool
  func whistleAction(contentID: Int, method: HTTPMethod) async
  func actionContentHate(contentID: Int, method: HTTPMethod) async
  func deleteContent(contentID: Int) async
  func reportContent(userID: Int, contentID: Int, reportReason: Int, reportDescription: String) async -> Int
  func reportUser(usedID: Int, contentID: Int, reportReason: Int, reportDescription: String) async -> Int
  func addViewCount(_ viewCount: ViewCount, notInclude: Set<Int>, completion: @escaping ([ViewCountModel]) -> Void)
  func requestGuestFeed(completion: @escaping () -> Void)
  func requestUniversalFeed(contentID: Int, completion: @escaping () -> Void)
}
