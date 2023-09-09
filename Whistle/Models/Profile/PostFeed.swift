//
//  PostFeed.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class PostFeed: ObservableObject, Codable {

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
  }

  var userId: Int?
  var userName: String?
  var profileImg: String?
  var caption: String?
  var videoUrl: String?
  var musicSinger: String?
  var musicName: String?
  var hashtags: String?
  var contentWhistleCount: Int?
  var contentViewCount: Int?
  var isWhistled: Int?
}
