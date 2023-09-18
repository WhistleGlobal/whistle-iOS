//
//  MyProfile.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

// MARK: - Profile

class Profile: ObservableObject, Decodable {

  enum CodingKeys: String, CodingKey {
    case userName = "user_name"
    case email
    case profileImage = "profile_img"
    case introduce
    case status
  }

  var userName = ""
  var email = ""
  var profileImage: String?
  var introduce: String?
  var status: UserStatus = .active
}

// MARK: - UserStatus

public enum UserStatus: String, Codable {
  case active = "활성화"
  case inactive = "비활성화"
  case suspended = "기간정지"
  case banned = "영구정지"

  // MARK: Lifecycle

  // Custom initializer to map Korean values to English cases
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let koreanValue = try container.decode(String.self)

    switch koreanValue {
    case "활성화":
      self = .active
    case "비활성화":
      self = .inactive
    case "기간정지":
      self = .suspended
    case "영구정지":
      self = .banned
    default:
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid user status: \(koreanValue)")
    }
  }
}
