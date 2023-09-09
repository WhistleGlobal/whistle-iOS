//
//  Content.swift
//  Whistle
//
//  Created by ChoiYujin on 9/9/23.
//

import AVFoundation
import Foundation

class MainContent: Hashable {

  // MARK: Lifecycle

  init(
    id: UUID = UUID(),
    player: AVPlayer? = nil,
    userId: Int? = nil,
    userName: String? = nil,
    profileImg: String? = nil,
    caption: String? = nil,
    videoUrl: String? = nil,
    musicArtist: String? = nil,
    musicTitle: String? = nil,
    hashtags: String? = nil,
    whistleCount: Int? = nil,
    isWhistled: Bool? = nil,
    isFollowed: Bool? = nil,
    isBookmarked: Bool? = nil)
  {
    self.id = id
    self.player = player
    self.userId = userId
    self.userName = userName
    self.profileImg = profileImg
    self.caption = caption
    self.videoUrl = videoUrl
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
  var player: AVPlayer?
  var userId: Int?
  var userName: String?
  var profileImg: String?
  var caption: String?
  var videoUrl: String?
  var musicArtist: String?
  var musicTitle: String?
  var hashtags: String?
  var whistleCount: Int?
  var isWhistled: Bool?
  var isFollowed: Bool?
  var isBookmarked: Bool?


  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: MainContent, rhs: MainContent) -> Bool {
    lhs.id == rhs.id
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
