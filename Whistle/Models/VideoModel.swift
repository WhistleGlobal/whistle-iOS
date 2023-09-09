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
