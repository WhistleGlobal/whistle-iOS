//
//  SettingProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation

protocol SettingProtocol {
  func requestNotiSetting() async
  func updateSettingWhistle(newSetting: Bool) async
  func updateSettingFollow(newSetting: Bool) async
  func updateSettingInfo(newSetting: Bool) async
  func updateSettingAd(newSetting: Bool) async
  func uploadDeviceToken(deviceToken: String, completion: @escaping () -> Void)
  func requestVersionCheck() async
}
