//
//  MyContent.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class MyContent: ObservableObject, Decodable, Hashable {
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
    case whistleCount = "content_whistle_count"
    case viewCount = "content_view_count"
    case isWhistled = "is_whistled"
    case isBookmarked = "is_bookmarked"
    case aspectRatio = "aspect_ratio"
  }

  @Published var contentId: Int?
  @Published var userId: Int?
  @Published var userName: String?
  @Published var profileImg: String?
  @Published var caption: String?
  @Published var videoUrl: String?
  @Published var thumbnailUrl: String?
  @Published var musicArtist: String?
  @Published var musicTitle: String?
  @Published var hashtags: [String]?
  @Published var whistleCount: Int
  @Published var viewCount: Int?
  @Published var isWhistled = false
  @Published var isBookmarked = false
  @Published var aspectRatio: Double?
  var isFollowed = false

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
    whistleCount = try container.decode(Int?.self, forKey: .whistleCount) ?? 0
    viewCount = try container.decode(Int?.self, forKey: .viewCount)
    isWhistled = try container.decode(Int.self, forKey: .isWhistled) == 1
    isBookmarked = try container.decode(Int?.self, forKey: .isBookmarked) == 1
    aspectRatio = try container.decode(Double?.self, forKey: .aspectRatio)
  }

  static func == (lhs: MyContent, rhs: MyContent) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}
