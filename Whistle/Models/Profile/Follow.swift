//
//  Follow.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

// MARK: - Follow

class Follow: Codable {

  // MARK: Lifecycle

  init(
    followingList: [FollowingData] = [],
    followingCount: Int = 0,
    followerList: [FollowerData] = [],
    followerCount: Int = 0)
  {
    self.followingList = followingList
    self.followingCount = followingCount
    self.followerList = followerList
    self.followerCount = followerCount
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case followingList = "following_list"
    case followingCount = "following_count"
    case followerList = "follower_list"
    case followerCount = "follower_count"
  }

  var followingList: [FollowingData]
  var followingCount: Int
  var followerList: [FollowerData]
  var followerCount: Int

}

// MARK: - FollowingData

class FollowingData: Codable {

  enum CodingKeys: String, CodingKey {
    case followingId = "following_id"
    case userName = "user_name"
    case profileImg = "profile_img"
  }

  var followingId: Int
  var userName: String
  var profileImg: String?
}

// MARK: - FollowerData

class FollowerData: Codable {

  // MARK: Lifecycle

  init(followerId: Int, userName: String, profileImg: String? = nil, isFollowed: Int) {
    self.followerId = followerId
    self.userName = userName
    self.profileImg = profileImg
    self.isFollowed = isFollowed
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case followerId = "follower_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case isFollowed = "is_followed"
  }

  var followerId: Int
  var userName: String
  var profileImg: String?
  var isFollowed: Int
}
