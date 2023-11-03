//
//  NotificationModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/2/23.
//

import Foundation

class NotificationModel {


  var notificationID: Int?
  var senderID: Int?
  var recieverID: Int?
  var contentID: Int?
  var notificationType: NotificationType?
  var notificationCaption: String?
//    var notificationTime =



  public enum NotificationType: String, Codable {
    case whistle = "휘슬"
    case follow = "팔로우"
    case info = "정보"
    case ad = "광고"

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let koreanValue = try container.decode(String.self)

      switch koreanValue {
      case "휘슬":
        self = .whistle
      case "팔로우":
        self = .follow
      case "정보":
        self = .info
      case "광고":
        self = .ad
      default:
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Invalid user status: \(koreanValue)")
      }
    }
    // m('휘슬, '팔로우, '정보; 광고
  }
  // public init(from decoder: Decoder) throws {
  //  let container = try decoder.singleValueContainer()
  //  let koreanValue = try container.decode(String.self)
  //
  //  switch koreanValue {
  //  case "활성화":
  //    self = .active
  //  case "비활성화":
  //    self = .inactive
  //  case "기간정지":
  //    self = .suspended
  //  case "영구정지":
  //    self = .banned
  //  default:
  //    throw DecodingError.dataCorruptedError(
  //      in: container,
  //      debugDescription: "Invalid user status: \(koreanValue)")
  //  }
  // }
}

// // MARK: - MyProfile
//
// class MyProfile: ObservableObject, Decodable {
//  enum CodingKeys: String, CodingKey {
//    case userId = "user_id"
//    case userName = "user_name"
//    case email
//    case profileImage = "profile_img"
//    case introduce
//    case status
//  }
//
//  var userId = 0
//  var userName = ""
//  var email = ""
//  var profileImage: String?
//  var introduce: String?
//  var status: UserStatus = .active
// }
//
// // MARK: - UserStatus
//
// public enum UserStatus: String, Codable {
//  case active = "활성화"
//  case inactive = "비활성화"
//  case suspended = "기간정지"
//  case banned = "영구정지"
//
//  // MARK: Lifecycle
//
//  // Custom initializer to map Korean values to English cases
//  public init(from decoder: Decoder) throws {
//    let container = try decoder.singleValueContainer()
//    let koreanValue = try container.decode(String.self)
//
//    switch koreanValue {
//    case "활성화":
//      self = .active
//    case "비활성화":
//      self = .inactive
//    case "기간정지":
//      self = .suspended
//    case "영구정지":
//      self = .banned
//    default:
//      throw DecodingError.dataCorruptedError(
//        in: container,
//        debugDescription: "Invalid user status: \(koreanValue)")
//    }
//  }
// }
