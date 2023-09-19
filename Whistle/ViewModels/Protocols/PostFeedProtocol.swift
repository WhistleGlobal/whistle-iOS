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
  func actionBookmark(contentId: Int) async
}
