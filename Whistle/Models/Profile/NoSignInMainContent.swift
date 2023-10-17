//
//  NoSignInMainContent.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import AVFoundation
import Foundation

class NoSignInMainContent: Hashable, ObservableObject {
  // MARK: Lifecycle

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
    hashtags: String? = nil,
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
  var hashtags: String?
  var whistleCount: Int?

  // Equatable conformance for completeness (optional but recommended)
  static func == (lhs: NoSignInMainContent, rhs: NoSignInMainContent) -> Bool {
    lhs.id == rhs.id
  }

  // Implementing the hash(into:) method to make User hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
