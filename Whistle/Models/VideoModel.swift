//
//  VideoModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import AVFoundation
import Foundation

// MARK: - Video
// FIXME: - API 연동시 Underscore -> lowerCamelCase
struct Video: Identifiable {
  var id = UUID()
  var player: AVPlayer
  var user_name: String
  var profile_img: String
  var caption: String
  var video_url: String
  var music_singer: String
  var music_name: String
  var hashtags: String
  var content_whistle_count: Int
  var content_view_count: String
  var is_whistled: Bool
  var is_followed: Bool
  var is_bookmarked: Bool
}

// {
//        "user_id": 3,
//        "user_name": "dayjack",
//        "profile_img": "https://whistle-bucket.s3.amazonaws.com/user/3/profile_image/image-1694159714065-3p8.jpg",
//        "caption": "더미 캡션",
//        "video_url": "https://whistle-bucket.s3.ap-northeast-2.amazonaws.com/user/3/content/agigangaji-ibyang-hu-1280.mp4",
//        "music_artist": null,
//        "music_title": null,
//        "hashtags": null,
//        "content_whistle_count": 1,
//        "is_whistled": 1,
//        "is_followed": 0,
//        "is_bookmarked": 0
//    }
