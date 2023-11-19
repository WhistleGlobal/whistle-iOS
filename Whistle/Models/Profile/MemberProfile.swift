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
    case status = "user_status"
    case isFollowed = "is_followed"
    case isBlocked = "is_blocked"
  }

  var userId = 0
  var userName = ""
  var profileImg: String?
  var introduce: String?
  var status: UserStatus = .active
  var isFollowed = false
  var isBlocked = false

  init() { }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    userId = try container.decode(Int.self, forKey: .userId)
    userName = try container.decode(String.self, forKey: .userName)
    profileImg = try container.decode(String?.self, forKey: .profileImg)
    introduce = try container.decode(String?.self, forKey: .introduce)
    status = try container.decode(UserStatus.self, forKey: .status)
    status = try container.decode(UserStatus.self, forKey: .status)
    isFollowed = try container.decode(Int.self, forKey: .isFollowed) == 1 ? true : false
    isBlocked = try container.decode(Int.self, forKey: .isBlocked) == 1 ? true : false
  }
}
