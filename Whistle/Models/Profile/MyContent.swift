//
//  MyContent.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class MyContent: ObservableObject, Codable, Hashable {
  enum CodingKeys: String, CodingKey {
    case contentId = "content_id"
    case userId = "user_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case caption
    case videoUrl = "video_url"
    case thumbnailUrl = "thumbnail_url"
    case musicArtist = "music_artist"
    case musicTitle = "music_title"
    case hashtags = "content_hashtags"
    case contentWhistleCount = "content_whistle_count"
    case contentViewCount = "content_view_count"
    case isWhistled = "is_whistled"
  }

  var contentId: Int?
  var userId: Int?
  var userName: String?
  var profileImg: String?
  var caption: String?
  var videoUrl: String?
  var thumbnailUrl: String?
  var musicArtist: String?
  var musicTitle: String?
  var hashtags: [String]?
  var contentWhistleCount: Int?
  var contentViewCount: Int?
  var isWhistled = false

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    contentId = try container.decode(Int.self, forKey: .contentId)
    userId = try container.decode(Int.self, forKey: .userId)
    userName = try container.decode(String.self, forKey: .userName)
    profileImg = try container.decode(String?.self, forKey: .profileImg)
    caption = try container.decode(String?.self, forKey: .caption)
    videoUrl = try container.decode(String?.self, forKey: .videoUrl)
    thumbnailUrl = try container.decode(String?.self, forKey: .thumbnailUrl)
    musicArtist = try container.decode(String?.self, forKey: .musicArtist)
    musicTitle = try container.decode(String?.self, forKey: .musicTitle)
    hashtags = try container.decode([String]?.self, forKey: .hashtags)
    contentWhistleCount = try container.decode(Int?.self, forKey: .contentWhistleCount)
    contentViewCount = try container.decode(Int?.self, forKey: .contentViewCount)
    isWhistled = try container.decode(Int.self, forKey: .isWhistled) == 1 ? true : false
  }

  static func == (lhs: MyContent, rhs: MyContent) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}
