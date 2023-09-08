//
//  PostFeedProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation

protocol PostFeedProtocol {

  func requestMyPostFeed() async
  func requestUserPostFeed(userId: Int) async
  func requestMyBookmark() async
}
