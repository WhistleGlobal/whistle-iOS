//
//  ProfileProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Alamofire

protocol ProfileProtocol {
  func requestMyProfile() async
  func updateMyProfile() async -> ProfileEditIDView.InputValidationStatus
  func requestMemberProfile(userID: Int) async
  func requestMyWhistlesCount() async
  func requestMemberWhistlesCount(userID: Int) async
  func requestMyFollow() async
  func requestMemberFollow(userID: Int) async
  func isAvailableUsername() async -> Bool
  func deleteProfileImage() async
  // FIXME: - 차단: blockAction, 팔로우: followAction
  func followUser(userID: Int) async
  func unfollowUser(userID: Int) async
  func rebokeAppleToken() async
  func actionBlockUser(userID: Int) async
  func actionBlockUserCancel(userID: Int) async
}
