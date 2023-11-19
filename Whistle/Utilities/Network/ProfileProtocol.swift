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
  func followAction(userID: Int, method: HTTPMethod) async
  func rebokeAppleToken() async
  func blockAction(userID: Int, method: HTTPMethod) async
  func updateMyTeam(myTeam: String) async
}
