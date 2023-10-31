//
//  BookMark.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class Bookmark: ObservableObject, Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case contentId = "content_id"
    case userId = "user_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case caption
    case videoUrl = "video_url"
    case thumbnailUrl = "thumbnail_url"
    case musicArtist = "music_singer"
    case musicTitle = "music_name"
    case hashtags = "content_hashtags"
    case whistleCount = "content_whistle_count"
    case viewCount = "content_view_count"
    case isWhistled = "is_whistled"
    case isFollowed = "is_followed"
    case isBookmarked = "is_bookmarked"
  }

  var contentId = 0
  var userId = 0
  var userName = ""
  var profileImg: String?
  var caption: String?
  var videoUrl = ""
  var thumbnailUrl = ""
  var musicArtist: String?
  var musicTitle: String?
  var hashtags: [String] = []
  var whistleCount = 0
  var viewCount = 0
  var isWhistled = false
  var isFollowed = false
  var isBookmarked = false

  init() { }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    contentId = try container.decode(Int.self, forKey: .contentId)
    userId = try container.decode(Int.self, forKey: .userId)
    userName = try container.decode(String.self, forKey: .userName)
    profileImg = try container.decode(String?.self, forKey: .profileImg)
    caption = try container.decode(String?.self, forKey: .caption)
    videoUrl = try container.decode(String.self, forKey: .videoUrl)
    thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
    musicArtist = try container.decode(String?.self, forKey: .musicArtist)
    musicTitle = try container.decode(String?.self, forKey: .musicTitle)
    hashtags = try container.decode([String].self, forKey: .hashtags)
    whistleCount = try container.decode(Int.self, forKey: .whistleCount)
    viewCount = try container.decode(Int.self, forKey: .viewCount)
    isWhistled = try container.decode(Int.self, forKey: .isWhistled) == 1 ? true : false
    isFollowed = try container.decode(Int.self, forKey: .isFollowed) == 1 ? true : false
    isBookmarked = try container.decode(Int.self, forKey: .isBookmarked) == 1 ? true : false
  }

  static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}
