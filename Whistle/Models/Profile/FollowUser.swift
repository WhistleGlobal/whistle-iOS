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
