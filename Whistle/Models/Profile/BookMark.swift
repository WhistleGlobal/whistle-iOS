//
//  BookMark.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class Bookmark: ObservableObject, Codable {

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case profileImg = "profile_img"
    case caption
    case videoUrl = "video_url"
    case musicSinger = "music_singer"
    case musicName = "music_name"
    case hashtags
    case contentWhistleCount = "content_whistle_count"
    case contentViewCount = "content_view_count"
    case isWhistled = "is_whistled"
    case isFollowed = "is_followed"
    case isBookmarked = "is_bookmarked"
    case isHated = "is_hated"
  }

  var userId = 0
  var userName = ""
  var profileImg = ""
  var caption = ""
  var videoUrl = ""
  var musicSinger = ""
  var musicName = ""
  var hashtags = ""
  var contentWhistleCount = 0
  var contentViewCount = 0
  var isWhistled = 0
  var isFollowed = 0
  var isBookmarked = 0
  var isHated = 0
}

