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
  func requestContentList() async
  func requestReportedConent() async
  func postFeedPlayerChanged()
  func actionBookmark(contentId: Int) async -> Bool
  func actionWhistle(contentId: Int) async
  func actionWhistleCancel(contentId: Int) async
  func actionContentHate(contentId: Int) async
  func deleteContent(contentId: Int) async
  func reportContent(contentId: Int, reportReason: Int, reportDescription: String) async -> Bool
}
