//
//  NotiSetting.swift
//  Whistle
//
//  Created by ChoiYujin on 9/6/23.
//

import Foundation

class NotiSetting: ObservableObject, Codable {

  enum CodingKeys: String, CodingKey {
    case whistleEnabled = "whistle_enabled"
    case followEnabled = "follow_enabled"
    case infoEnabled = "info_enabled"
    case adEnabled = "ad_enabled"
  }

  var whistleEnabled: Int?
  var followEnabled: Int?
  var infoEnabled: Int?
  var adEnabled: Int?
}
