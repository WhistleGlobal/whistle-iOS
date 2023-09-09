//
//  FollowUser.swift
//  Whistle
//
//  Created by ChoiYujin on 9/7/23.
//

import Foundation

class FollowUser: ObservableObject, Codable, Hashable {

  enum CodingKeys: String, CodingKey {
    case followingId = "following_id"
    case userName = "user_name"
    case profileImg = "profile_img"
  }

  var uuid = UUID()
  var followingId = ""
  var userName = ""
  var profileImg = ""


  static func == (lhs: FollowUser, rhs: FollowUser) -> Bool {
    lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}


// {
// "following": [
// {
// "following_id": 2,
// "user_name": "유저네임1",
// "profile_img": "프로필이미지_URL1"
// },
// ...
// ],
// "following_count": 10,
// "followers": [
// {
// "follower_id": 3,
// "user_name": "유저네임2",
// "profile_img": "프로필이미지_URL2",
// "is_followed": false
// },
// ...
// ],
// "follower_count": 12
// }

// let uuid = UUID()
// var userId = 0
// var userName = ""
// var email = ""
// var profileImg = ""
// var introduce: String?
// var country: String?
// var createdAt = Date()
// var status: UserStatus = .active
// var quitAt: Date?
//
// // Equatable conformance for completeness (optional but recommended)
// static func == (lhs: User, rhs: User) -> Bool {
//  lhs.uuid == rhs.uuid
// }
//
// // Implementing the hash(into:) method to make User hashable
// func hash(into hasher: inout Hasher) {
//  hasher.combine(uuid)
// }
