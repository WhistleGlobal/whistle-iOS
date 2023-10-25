//
//  MainContent.swift
//  Whistle
//
//  Created by ChoiYujin on 9/9/23.
//

import AVFoundation
import Foundation

class MainContent: Hashable, ObservableObject, Decodable {

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
    case isWhistled = "is_whistled"
    case isFollowed = "is_followed"
    case isBookmarked = "is_bookmarked"
  }

  // MARK: Lifecycle

  init(
    id: UUID = UUID(),
    contentId: Int? = nil,
    userId: Int? = nil,
    userName: String? = nil,
    profileImg: String? = nil,
    caption: String? = nil,
    videoUrl: String? = nil,
    thumbnailUrl: String? = nil,
    musicArtist: String? = nil,
    musicTitle: String? = nil,
    hashtags: [String]? = nil,
    whistleCount: Int = 0,
    isWhistled: Bool = false,
    isFollowed: Bool = false,
    isBookmarked: Bool = false)
  {
    self.id = id
    self.contentId = contentId
    self.userId = userId
    self.userName = userName
    self.profileImg = profileImg
    self.caption = caption
    self.videoUrl = videoUrl
    self.thumbnailUrl = thumbnailUrl
    self.musicArtist = musicArtist
    self.musicTitle = musicTitle
    self.hashtags = hashtags
    self.whistleCount = whistleCount
    self.isWhistled = isWhistled
    self.isFollowed = isFollowed
    self.isBookmarked = isBookmarked
  }

  // MARK: Internal

  var id = UUID()
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
  @Published var whistleCount: Int
  @Published var isWhistled: Bool
  var isFollowed = false
  var isBookmarked = false

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
    whistleCount = try container.decode(Int.self, forKey: .whistleCount)
    isWhistled = try container.decode(Int.self, forKey: .isWhistled) == 1
    isFollowed = try container.decode(Int.self, forKey: .isFollowed) == 1
    isBookmarked = try container.decode(Int.self, forKey: .isBookmarked) == 1
  }

  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: MainContent, rhs: MainContent) -> Bool {
    lhs.id == rhs.id
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
