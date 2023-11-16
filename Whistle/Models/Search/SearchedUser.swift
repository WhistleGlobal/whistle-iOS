//
//  SearchedUser.swift
//  Whistle
//
//  Created by ChoiYujin on 11/14/23.
//

import Foundation

class SearchedUser: Decodable {

  enum CodingKeys: String, CodingKey, Hashable {
    case userID = "user_id"
    case userName = "user_name"
    case profileImage = "profile_img"
    case introduce
  }

  var uuid = UUID()
  var userID = 0
  var userName = ""
  var profileImage: String?
  var introduce: String?

  static func == (lhs: SearchedUser, rhs: SearchedUser) -> Bool {
    lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}
