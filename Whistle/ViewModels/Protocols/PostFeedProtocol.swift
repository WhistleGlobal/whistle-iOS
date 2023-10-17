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
  func requestUserPostFeed(userId: Int) async
  func requestMyBookmark() async
  func requestContentList(completion: @escaping () -> Void)
  func requestReportedConent() async
  func postFeedPlayerChanged()
  func actionBookmark(contentId: Int) async -> Bool
  func actionBookmarkCancel(contentId: Int) async -> Bool
  func actionWhistle(contentId: Int) async
  func actionWhistleCancel(contentId: Int) async
  func actionContentHate(contentId: Int) async
  func deleteContent(contentId: Int) async
  func reportContent(userId: Int, contentId: Int, reportReason: Int, reportDescription: String) async -> Int
  func reportUser(usedId: Int, contentId: Int, reportReason: Int, reportDescription: String) async -> Int
  func addViewCount(_ viewCount: ViewCount, notInclude: Set<Int>, completion: @escaping ([ViewCountModel]) -> Void)
  func requestNoSignInContent(completion: @escaping () -> Void)
  func requestUniversalContent(contentId: Int, completion: @escaping () -> Void)
}
