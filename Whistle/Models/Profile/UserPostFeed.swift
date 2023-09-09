//
//  UserPostFeed.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class UserPostFeed: PostFeed {

  enum CodingKeys: String, CodingKey {
    case isFollowed = "is_followed"
    case isBookmarked = "is_bookmarked"
    case isHated = "is_hated"
  }

  var isFollowed: Int?
  var isBookmarked: Int?
  var isHated: Int?
}

// {
//       "user_id": 4,
//       "user_name": "juwon4669",
//       "profile_img": "",
//       "caption": "2",
//       "video_url": "https://whistle-bucket.s3.ap-northeast-2.amazonaws.com/user/4/content/hangug-jeonseolyi-4dae-gol-moeum-1280-ytshorts.savetube.me.mp4",
//       "music_artist": null,
//       "music_title": null,
//       "content_hashtags": null,
//       "content_whistle_count": 0,
//       "content_view_count": 0,
//
//       "is_followed": 0,
//       "is_bookmarked": 0,
//       "is_hated": 0
//   }
