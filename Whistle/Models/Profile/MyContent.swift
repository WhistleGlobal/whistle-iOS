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
    case contentWhistleCount = "content_whistle_count"
    case contentViewCount = "content_view_count"
    case isWhistled = "is_whistled"
    case isBookmarked = "is_bookmarked"
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
  @Published var contentWhistleCount: Int?
  @Published var contentViewCount: Int?
  @Published var isWhistled = false
  @Published var isBookmarked = false

  init() { }

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
    isWhistled = try container.decode(Int.self, forKey: .isWhistled) == 1
    isBookmarked = try container.decode(Int?.self, forKey: .isBookmarked) == 1
  }

  static func == (lhs: MyContent, rhs: MyContent) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}

