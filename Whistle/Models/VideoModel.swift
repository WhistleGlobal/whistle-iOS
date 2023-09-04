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
  var is_hated: Bool
}

// to. Front
// - user_name (유저 네임) [user]
// - profile_img (프로필 이미지) [user]
// - caption (본문) [content]
// - video_url (동영상 url) [video]
// - music_singer (노래 가수) [music]
// - music_name (노래 제목) [music]
// - hashtags (해시태그 모음 문자열)
// - content_whistle_count (콘텐츠 당 총 휘슬 수)
// - content_view_count (콘텐츠 당 총 조회수)
// - is_whistled (휘슬했는지 여부)
// - is_followed (팔로우했는지 여부)
// - is_bookmarked (저장했는지 여부)
// - is_hated (관심없음했는지 여부)
// struct Video: Identifiable {
//    var id = UUID()
//    var player : AVPlayer
//    var likes: String
//    var comments: String
//    var url: String
// }
