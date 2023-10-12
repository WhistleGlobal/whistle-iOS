//
//  PostFeed.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class PostFeed: ObservableObject, Codable, Hashable {

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
  var isWhistled: Int?

  static func == (lhs: PostFeed, rhs: PostFeed) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}
