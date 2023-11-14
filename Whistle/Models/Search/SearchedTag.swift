//
//  SearchedTag.swift
//  Whistle
//
//  Created by ChoiYujin on 11/14/23.
//

import Foundation

class SearchedTag: Decodable {

  enum CodingKeys: String, CodingKey, Hashable {
    case contentHashtag = "content_hashtag"
    case contentHashtagCount = "content_hashtag_count"
  }

  var uuid = UUID()
  var contentHashtag = ""
  var contentHashtagCount = 0

  static func == (lhs: SearchedTag, rhs: SearchedTag) -> Bool {
    lhs.uuid == rhs.uuid
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}
