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
  func requestUserProfile(userId: Int) async
  func requestMyWhistlesCount() async
  func requestUserWhistlesCount(userId: Int) async
  func requestMyFollow() async
  func requestUserFollow(userId: Int) async
  func isAvailableUsername() async -> Bool
  func deleteProfileImage() async
  func followUser(userId: Int) async
  func unfollowUser(userId: Int) async
  func rebokeAppleToken() async

}
