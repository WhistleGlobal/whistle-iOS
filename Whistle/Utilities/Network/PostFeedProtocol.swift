//
//  PostFeedProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation
import UIKit

protocol PostFeedProtocol {
  func requestMyPostFeed() async
  func requestMemberPostFeed(userID: Int) async
  func requestMyBookmark() async
  func requestMainFeed(completion: @escaping () -> Void)
  func requestReportedFeed() async
  // TODO: - MainView 정리 시 함께 정리
  func postFeedPlayerChanged()
  // FIXME: - 하나로 통합
  func actionBookmark(contentID: Int) async -> Bool
  func actionBookmarkCancel(contentID: Int) async -> Bool
  func actionWhistle(contentID: Int) async
  func actionWhistleCancel(contentID: Int) async
  func actionContentHate(contentID: Int) async
  func deleteContent(contentID: Int) async
  func reportContent(userID: Int, contentID: Int, reportReason: Int, reportDescription: String) async -> Int
  func reportUser(usedID: Int, contentID: Int, reportReason: Int, reportDescription: String) async -> Int
  func addViewCount(_ viewCount: ViewCount, notInclude: Set<Int>, completion: @escaping ([ViewCountModel]) -> Void)
  func requestGuestFeed(completion: @escaping () -> Void)
  func requestUniversalFeed(contentID: Int, completion: @escaping () -> Void)
}
