//
//  Follow.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class Follow: Observable, Codable {

  enum CodingKeys: String, CodingKey {
    case following
    case followingCount = "following_count"
    case followers
    case followerCount = "follower_count"
  }

  var following: [User] = []
  var followingCount = 0
  var followers: [User] = []
  var followerCount = 0
}
