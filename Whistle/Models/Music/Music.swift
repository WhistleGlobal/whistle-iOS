//
//  Music.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Foundation

class Music: ObservableObject, Codable {

  enum CodingKeys: String, CodingKey {
    case musicID = "music_id"
    case musicArtist = "music_artist"
    case musicTitle = "music_title"
    case musicURL = "music_url"
    case albumCover = "album_cover"
  }

  var musicID: Int
  var musicArtist: String?
  var musicTitle: String
  var musicURL: String
  var albumCover: String
}
