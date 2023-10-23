//
//  SettingProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation

protocol SettingProtocol {
  func requestNotiSetting() async
  func updateWhistleNoti(newSetting: Bool) async
  func updateFollowNoti(newSetting: Bool) async
  func updateServerNoti(newSetting: Bool) async
  func updateAdNoti(newSetting: Bool) async
  func uploadDeviceToken(deviceToken: String, completion: @escaping () -> Void)
  func requestVersionCheck() async
}
