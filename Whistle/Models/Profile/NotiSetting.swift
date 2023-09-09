//
//  NotiSetting.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class NotiSetting: ObservableObject, Codable {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    whistleEnabled = try container.decodeIfPresent(Int.self, forKey: .whistleEnabled) == 1
    followEnabled = try container.decodeIfPresent(Int.self, forKey: .followEnabled) == 1
    infoEnabled = try container.decodeIfPresent(Int.self, forKey: .infoEnabled) == 1
    adEnabled = try container.decodeIfPresent(Int.self, forKey: .adEnabled) == 1
  }

  init() {
    whistleEnabled = false
    followEnabled = false
    infoEnabled = false
    adEnabled = false
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case whistleEnabled = "whistle_enabled"
    case followEnabled = "follow_enabled"
    case infoEnabled = "info_enabled"
    case adEnabled = "ad_enabled"
  }

  var whistleEnabled: Bool
  var followEnabled: Bool
  var infoEnabled: Bool
  var adEnabled: Bool
}
