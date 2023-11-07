//
//  NoSignInMainContent.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import AVFoundation
import Foundation

class GuestContent: Hashable, ObservableObject, Codable {
  // MARK: Lifecycle
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
    case aspectRatio = "aspect_ratio"
  }

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
    whistleCount: Int? = nil)
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
  var whistleCount: Int?
  var aspectRatio: Double?

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
    hashtags = try container.decode([String]?.self, forKey: .hashtags)
    whistleCount = try container.decode(Int?.self, forKey: .whistleCount)
    aspectRatio = try container.decode(Double?.self, forKey: .aspectRatio)
  }

  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: GuestContent, rhs: GuestContent) -> Bool {
    lhs.id == rhs.id
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
