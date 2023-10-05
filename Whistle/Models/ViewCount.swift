//
//  ViewCount.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import Foundation

// MARK: - ViewCount

class ViewCount: Codable {
  var views: [ViewCountModel] = []

  enum CodingKeys: String, CodingKey {
    case views = "view"
  }
}

// MARK: - ViewCountModel

class ViewCountModel: Codable {
  var contentId = 0
  var viewTime = ""
  var viewDate = ""

  enum CodingKeys: String, CodingKey {
    case contentId = "content_id"
    case viewTime = "view_time"
    case viewDate = "view_date"
  }

  init(contentId: Int = 0, viewTime: String = "", viewDate: String = "") {
    self.contentId = contentId
    self.viewTime = viewTime
    self.viewDate = viewDate
  }
}
