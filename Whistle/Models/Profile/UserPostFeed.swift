//
//  UserPostFeed.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class UserPostFeed: PostFeed {

  enum CodingKeys: String, CodingKey {
    case isFollowed = "is_followed"
    case isBookmarked = "is_bookmarked"
    case isHated = "is_hated"
  }

  var isFollowed: Int?
  var isBookmarked: Int?
  var isHated: Int?
}
