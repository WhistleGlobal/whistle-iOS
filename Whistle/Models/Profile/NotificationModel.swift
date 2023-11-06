//
//  NotificationModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/2/23.
//

import Foundation

// MARK: - NotificationModel

class NotificationModel: Decodable, Hashable, ObservableObject {
  var uuid = UUID()
  var notificationID: Int
  var senderID: Int
  var recieverID: Int
  var contentID: Int?
  var userName: String
  @Published var isFollowed: Bool // 변경: Bool로 디코딩
  var profileImageURL: String?
  var thumbnailURL: String?
  var notificationType: NotificationType
  var notificationTitle: String?
  var notificationCaption: String?
  var notificationTime: Date
  var notificationRead: Bool // 변경: Bool로 디코딩

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
  }

  enum CodingKeys: String, CodingKey {
    case notificationID = "notification_id"
    case senderID = "sender_id"
    case recieverID = "reciever_id"
    case contentID = "content_id"
    case userName = "user_name"
    case isFollowed = "is_followed"
    case profileImageURL = "profile_img"
    case thumbnailURL = "thumbnail_url"
    case notificationType = "notification_type"
    case notificationTitle = "notification_title"
    case notificationCaption = "notification_body"
    case notificationTime = "notification_time"
    case notificationRead = "notification_read"
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    notificationID = try container.decode(Int.self, forKey: .notificationID)
    senderID = try container.decode(Int.self, forKey: .senderID)
    recieverID = try container.decode(Int.self, forKey: .recieverID)
    contentID = try container.decode(Int?.self, forKey: .contentID)
    userName = try container.decode(String.self, forKey: .userName)

    if let isFollowedInt = try? container.decode(Int.self, forKey: .isFollowed) {
      isFollowed = isFollowedInt == 1
    } else {
      isFollowed = false
    }

    profileImageURL = try container.decode(String?.self, forKey: .profileImageURL)
    thumbnailURL = try container.decode(String?.self, forKey: .thumbnailURL)
    notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
    notificationTitle = try container.decode(String?.self, forKey: .notificationTitle)
    notificationCaption = try container.decode(String?.self, forKey: .notificationCaption)
    let dateString = try container.decode(String.self, forKey: .notificationTime)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = dateFormatter.date(from: dateString) {
      notificationTime = date
    } else {
      throw DecodingError.dataCorruptedError(
        forKey: .notificationTime,
        in: container,
        debugDescription: "Invalid date format for notification_time")
    }
    if let notificationReadInt = try? container.decode(Int.self, forKey: .notificationRead) {
      notificationRead = notificationReadInt == 1
    } else {
      notificationRead = false
    }
  }
}

extension NotificationModel {
  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: NotificationModel, rhs: NotificationModel) -> Bool {
    lhs.uuid == rhs.uuid
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}
