//
//  Follow.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

// MARK: - Follow

class Follow: Decodable {

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

  @Published var followingList: [FollowingData]
  @Published var followingCount: Int
  @Published var followerList: [FollowerData]
  @Published var followerCount: Int

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    followingList = try container.decode([FollowingData].self, forKey: .followingList)
    followingCount = try container.decode(Int.self, forKey: .followingCount)
    followerList = try container.decode([FollowerData].self, forKey: .followerList)
    followerCount = try container.decode(Int.self, forKey: .followerCount)
  }
}

// MARK: - UserFollow

class UserFollow: Decodable {

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
    case followingList = "following"
    case followingCount = "following_count"
    case followerList = "followers"
    case followerCount = "follower_count"
  }

  var followingList: [FollowingData]
  var followingCount: Int
  var followerList: [FollowerData]
  var followerCount: Int
}

// MARK: - FollowingData

class FollowingData: Decodable {

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

class FollowerData: Decodable {

  // MARK: Lifecycle

  init(followerId: Int, userName: String, profileImg: String?, isFollowed: Bool) {
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
  var isFollowed: Bool

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    followerId = try container.decode(Int.self, forKey: .followerId)
    userName = try container.decode(String.self, forKey: .userName)
    profileImg = try container.decodeIfPresent(String.self, forKey: .profileImg)
    isFollowed = try container.decode(Int.self, forKey: .isFollowed) == 1 ? true : false
  }
}
