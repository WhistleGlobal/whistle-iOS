//
//  ReportedContent.swift
//  Whistle
//
//  Created by ChoiYujin on 9/10/23.
//

import Foundation

class ReportedContent: Hashable, Decodable {

  // MARK: Public

  public enum ConentStatus: String, Codable {
    case active = "활성화"
    case inactive = "비활성화"
    case removed = "삭제"

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let koreanValue = try container.decode(String.self)
      switch koreanValue {
      case "활성화":
        self = .active
      case "비활성화":
        self = .inactive
      case "삭제":
        self = .removed
      default:
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Invalid user status: \(koreanValue)")
      }
    }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case videoUrl = "video_url"
    case thumbnailUrl = "thumbnail_url"
    case caption
    case status
    case whistleCount = "content_whistle_count"
    case musicArtist = "music_artist"
    case musicTitle = "music_title"
    case hashtags = "content_hashtags"
    case viewCounts = "content_view_count"
    case isWhistled = "is_whistled"

  }

  var userId = 0
  var userName = ""
  var profileImg: String?
  var videoUrl = ""
  var thumbnailUrl = ""
  var caption = ""
  var status: ConentStatus = .inactive
  var whistleCount = 0
  var musicArtist: String?
  var musicTitle: String?
  var hashtags: String?
  var viewCounts = 0
  var isWhistled = 0

  static func == (lhs: ReportedContent, rhs: ReportedContent) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}
