//
//  BookMark.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class Bookmark: ObservableObject, Codable, Hashable {

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case caption
    case videoUrl = "video_url"
    case musicArtist = "music_artist"
    case musicTitle = "music_title"
    case hashtags = "content_hashtags"
    case whistleCount = "content_whistle_count"
    case viewCount = "content_view_count"
    case isWhistled = "is_whistled"
    case isFollowed = "is_followed"
    case isBookmarked = "is_bookmarked"
  }

  var userId = 0
  var userName = ""
  var profileImg: String?
  var caption: String?
  var videoUrl = ""
  var musicArtist: String?
  var musicTitle: String?
  var hashtags: String?
  var whistleCount = 0
  var viewCount = 0
  var isWhistled = 0
  var isFollowed = 0
  var isBookmarked = 0

  static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
    lhs.videoUrl == rhs.videoUrl
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(videoUrl)
  }
}
