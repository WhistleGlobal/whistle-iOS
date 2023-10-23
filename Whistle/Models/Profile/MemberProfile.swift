//
//  MemberProfile.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class MemberProfile: ObservableObject, Codable {
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case introduce
    case status
    case isFollowed = "is_followed"
    case isBlocked = "is_blocked"
  }

  var userId = 0
  var userName = ""
  var profileImg: String?
  var introduce: String?
  var status: UserStatus = .active
  var isFollowed = 0
  var isBlocked = 0
}
